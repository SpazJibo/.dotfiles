#!/usr/bin/python3
"""Default-route throughput; graph shows rolling, peak-scaled RX+TX."""
import fcntl
import json
import os
from pathlib import Path
import re
import subprocess
import time

WIDTH = 36


def rates(previous, current):
    if not previous or previous['interface'] != current['interface']:
        return 0, 0
    elapsed = current['time'] - previous['time']
    if elapsed <= 0 or elapsed > 30:
        return 0, 0
    return tuple(max(0, current[key] - previous[key]) / elapsed for key in ('rx', 'tx'))


def normalized_history(history):
    peak = max(max(history, default=0), 1024)
    return [value / peak for value in history]


def format_rate(value):
    if value >= 1024 ** 2:
        return f'{value / 1024 ** 2:.1f}M'
    if value >= 1024:
        return f'{value / 1024:.0f}K'
    return f'{value:.0f}B'


def main():
    cache = Path.home() / 'Library/Caches/sketchybar'
    cache.mkdir(parents=True, exist_ok=True)
    with (cache / 'network.lock').open('w') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        state_path = cache / 'network.json'
        try:
            state = json.loads(state_path.read_text())
        except (OSError, ValueError):
            state = {}
        route = subprocess.run(['/sbin/route', '-n', 'get', 'default'], capture_output=True, text=True)
        match = re.search(r'interface:\s+(\S+)', route.stdout)
        interface = match.group(1) if match else ''
        output = subprocess.check_output(['/usr/sbin/netstat', '-ibn'], text=True)
        current = None
        for line in output.splitlines()[1:]:
            fields = line.split()
            if len(fields) >= 10 and fields[0].rstrip('*') == interface and fields[2].startswith('<Link#'):
                current = dict(interface=interface, time=time.monotonic(), rx=int(fields[6]), tx=int(fields[9]))
                break
        name = os.environ.get('NAME', 'network')
        if current is None:
            subprocess.run(['sketchybar', '--set', name, 'label=offline', '--push', name, '0'], check=True)
            state_path.unlink(missing_ok=True)
            return
        previous = state.get('sample')
        down, up = rates(previous, current)
        history = state.get('history', []) if previous and previous['interface'] == interface else []
        history = (history + [down + up])[-WIDTH:]
        points = [0] * (WIDTH - len(history)) + normalized_history(history)
        subprocess.run(['sketchybar', '--set', name, f'label=↓{format_rate(down)} ↑{format_rate(up)}/s',
                        '--push', name] + [f'{point:.5f}' for point in points], check=True)
        temporary = state_path.with_suffix('.new')
        temporary.write_text(json.dumps(dict(sample=current, history=history)))
        temporary.replace(state_path)


if __name__ == '__main__':
    main()

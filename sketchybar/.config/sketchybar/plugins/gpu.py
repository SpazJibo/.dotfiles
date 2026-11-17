#!/usr/bin/python3
"""GPU active-state residency, matching btop 1.4.8's Apple Silicon metric."""
import ctypes as C
import json
import sys
import time


def read_counters():
    """Read cumulative GPUPH states; no root, subprocess, or sampling sleep."""
    cf = C.CDLL('/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation')
    io = C.CDLL('/usr/lib/libIOReport.dylib')
    ptr, long, int32, uint64 = C.c_void_p, C.c_long, C.c_int32, C.c_uint64

    def bind(lib, name, result, *args):
        fn = getattr(lib, name)
        fn.restype, fn.argtypes = result, list(args)
        return fn

    release = bind(cf, 'CFRelease', None, ptr)
    string = bind(cf, 'CFStringCreateWithCString', ptr, ptr, C.c_char_p, C.c_uint32)
    copy = bind(cf, 'CFDictionaryCreateMutableCopy', ptr, ptr, long, ptr)
    get = bind(cf, 'CFDictionaryGetValue', ptr, ptr, ptr)
    count = bind(cf, 'CFArrayGetCount', long, ptr)
    at = bind(cf, 'CFArrayGetValueAtIndex', ptr, ptr, long)
    text = bind(cf, 'CFStringGetCString', C.c_bool, ptr, C.c_char_p, long, C.c_uint32)
    channels_in = bind(io, 'IOReportCopyChannelsInGroup', ptr, ptr, ptr, uint64, uint64, uint64)
    subscribe = bind(io, 'IOReportCreateSubscription', ptr, ptr, ptr, C.POINTER(ptr), uint64, ptr)
    sample = bind(io, 'IOReportCreateSamples', ptr, ptr, ptr, ptr)
    channel_name = bind(io, 'IOReportChannelGetChannelName', ptr, ptr)
    state_count = bind(io, 'IOReportStateGetCount', int32, ptr)
    state_name = bind(io, 'IOReportStateGetNameForIndex', ptr, ptr, int32)
    residency = bind(io, 'IOReportStateGetResidency', C.c_int64, ptr, int32)
    owned = []

    def own(value):
        if not value:
            raise RuntimeError('GPU IOReport telemetry is unavailable')
        owned.append(value)
        return value

    def decode(value):
        buf = C.create_string_buffer(128)
        if not value or not text(value, buf, len(buf), 0x08000100):
            raise RuntimeError('Invalid IOReport state name')
        return buf.value.decode('utf-8')

    try:
        group = own(string(None, b'GPU Stats', 0x08000100))
        subgroup = own(string(None, b'GPU Performance States', 0x08000100))
        base = own(channels_in(group, subgroup, 0, 0, 0))
        channels = own(copy(None, 0, base))
        out = ptr()
        subscription = own(subscribe(None, channels, C.byref(out), 0, None))
        if out.value:
            owned.append(out.value)
        current = own(sample(subscription, channels, None))
        key = own(string(None, b'IOReportChannels', 0x08000100))
        items = get(current, key)
        for i in range(count(items) if items else 0):
            item = at(items, i)
            if decode(channel_name(item)) == 'GPUPH':
                states = [[decode(state_name(item, s)), int(residency(item, s))]
                          for s in range(state_count(item))]
                if not states:
                    break
                return {'time': time.clock_gettime(time.CLOCK_MONOTONIC_RAW), 'states': states}
        raise RuntimeError('GPU GPUPH residency channel is unavailable')
    finally:
        for value in reversed(owned):
            release(value)


def interval_usage(previous, current):
    if not previous or not 0 < current['time'] - previous['time'] <= 30:
        return None
    before, after = previous['states'], current['states']
    if not after or [s[0] for s in before] != [s[0] for s in after]:
        return None
    deltas = [new[1] - old[1] for old, new in zip(before, after)]
    total = sum(deltas)
    if total <= 0 or any(value < 0 for value in deltas):
        return None
    offset = 0
    for index, (name, _) in enumerate(after):
        if name in ('IDLE', 'OFF', 'DOWN'):
            offset = index + 1
    return 100.0 * sum(deltas[offset:]) / total


def main():
    import fcntl
    import math
    import os
    from pathlib import Path
    import subprocess

    cache = Path(os.environ.get('SKETCHYBAR_GPU_CACHE', str(Path.home() / 'Library/Caches/sketchybar')))
    cache.mkdir(parents=True, exist_ok=True)
    name = os.environ.get('NAME', 'gpu')
    state_path = cache / 'gpu.json'
    with (cache / 'gpu.lock').open('w') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        try:
            try:
                previous = json.loads(state_path.read_text())
            except (OSError, ValueError):
                previous = None
            current = read_counters()
            usage = interval_usage(previous, current)
            current['percent'] = usage
            current['source'] = 'IOReport GPUPH active residency'
            temporary = state_path.with_suffix('.new')
            temporary.write_text(json.dumps(current))
            temporary.replace(state_path)
            label = '…' if usage is None else f'{math.floor(usage + 0.5)}%'
            subprocess.run(['sketchybar', '--set', name, 'icon=󰢮', f'label={label}'], check=True)
            if usage is not None:
                subprocess.run(['sketchybar', '--push', name, f'{usage / 100:.6f}'], check=True)
        except (OSError, RuntimeError, ValueError, TypeError, KeyError, IndexError) as exc:
            state_path.unlink(missing_ok=True)
            subprocess.run(['sketchybar', '--set', name, 'label=N/A'], check=True)
            print(f'GPU telemetry: {exc}', file=sys.stderr)


if __name__ == '__main__':
    if '--sample' in sys.argv:
        print(json.dumps(read_counters()))
    else:
        main()

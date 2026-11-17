import importlib.util
from pathlib import Path
import unittest

MODULE = Path(__file__).resolve().parents[1] / 'plugins/gpu.py'

class GPUMetricsTests(unittest.TestCase):
    def test_interval_uses_active_residency_not_driver_utilization(self):
        self.assertTrue(MODULE.exists(), 'IOReport collector is missing')
        spec = importlib.util.spec_from_file_location('gpu_metrics', MODULE)
        assert spec is not None and spec.loader is not None
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        self.module = module
        previous = {'time': 10, 'states': [['OFF', 1000], ['P1', 100], ['P2', 100]]}
        current = {'time': 12, 'states': [['OFF', 1158], ['P1', 121], ['P2', 121]]}
        self.assertAlmostEqual(module.interval_usage(previous, current), 21.0)
        self.assertIsNone(module.interval_usage(None, current))
        self.assertIsNone(module.interval_usage(current, current))
        self.assertIsNone(module.interval_usage(current, previous))
        self.assertIsNone(module.interval_usage(previous, dict(current, time=100)))
        self.assertIsNone(module.interval_usage(previous, dict(current, states=[['OFF', 1200]])))
        self.assertEqual(module.interval_usage(previous, dict(current, states=[['OFF', 1200], ['P1', 100], ['P2', 100]])), 0)
        self.assertEqual(module.interval_usage(previous, dict(current, states=[['OFF', 1000], ['P1', 200], ['P2', 200]])), 100)

    def test_live_counters_are_monotonic_across_processes(self):
        import json
        import subprocess
        import sys
        import time
        spec = importlib.util.spec_from_file_location('gpu_metrics', MODULE)
        assert spec is not None and spec.loader is not None
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        self.assertTrue(hasattr(module, 'read_counters'), 'native IOReport reader is missing')
        def sample():
            return json.loads(subprocess.check_output([sys.executable, str(MODULE), '--sample'], text=True))
        before = sample()
        time.sleep(0.2)
        after = sample()
        self.assertGreaterEqual(after['time'] - before['time'], 0.15,
                                'timestamps must share a system-wide clock across processes')
        self.assertEqual([s[0] for s in before['states']], [s[0] for s in after['states']])
        self.assertTrue(all(b[1] >= a[1] for a, b in zip(before['states'], after['states'])))
        usage = module.interval_usage(before, after)
        self.assertIsNotNone(usage, 'native counters must support interval deltas across plugin invocations')
        self.assertTrue(0 <= usage <= 100)

    def test_cli_warms_up_then_pushes_a_real_interval(self):
        import json
        import os
        import subprocess
        import sys
        import tempfile
        import time
        with tempfile.TemporaryDirectory(dir=os.environ['TMPDIR']) as tmp:
            root = Path(tmp)
            stub = root / 'sketchybar'
            stub.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >> "$CAPTURE"\n')
            stub.chmod(0o755)
            capture = root / 'calls'
            env = dict(os.environ, NAME='gpu_test', CAPTURE=str(capture),
                       SKETCHYBAR_GPU_CACHE=str(root / 'state'), PATH=tmp + ':' + os.environ['PATH'])
            command = [sys.executable, str(MODULE)]
            subprocess.run(command, env=env, check=True)
            self.assertTrue(capture.exists(), 'plugin did not update SketchyBar')
            self.assertNotIn('--push', capture.read_text(), 'warmup must not fabricate a zero')
            time.sleep(0.2)
            subprocess.run(command, env=env, check=True)
            pushes = [line.split() for line in capture.read_text().splitlines() if line.startswith('--push gpu_test ')]
            self.assertEqual(len(pushes), 1)
            self.assertTrue(0 <= float(pushes[0][2]) <= 1)
            state = json.loads((root / 'state/gpu.json').read_text())
            self.assertAlmostEqual(float(pushes[0][2]), state['percent'] / 100, places=5)
            # A third separate invocation proves cached state remains usable.
            time.sleep(0.1)
            subprocess.run(command, env=env, check=True)
            self.assertEqual(capture.read_text().count('--push gpu_test '), 2)

    def test_shell_entrypoint_uses_ioreport_collector(self):
        import os
        import subprocess
        import tempfile
        with tempfile.TemporaryDirectory(dir=os.environ['TMPDIR']) as tmp:
            root = Path(tmp)
            stub = root / 'sketchybar'
            stub.write_text('#!/bin/sh\nexit 0\n')
            stub.chmod(0o755)
            env = dict(os.environ, NAME='gpu_test', SKETCHYBAR_GPU_CACHE=tmp,
                       PATH=tmp + ':' + os.environ['PATH'])
            subprocess.run(['/bin/sh', str(MODULE.with_suffix('.sh'))], env=env, check=True)
            self.assertTrue((root / 'gpu.json').exists(), 'bar entrypoint is still using driver snapshots')

if __name__ == '__main__':
    unittest.main()

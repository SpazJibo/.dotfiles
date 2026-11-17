#!/bin/sh

# Interval-based GPU active residency, matching btop's Apple Silicon collector.
# Keep this entrypoint so the existing bar configuration remains unchanged.
exec /usr/bin/python3 "$(dirname "$0")/gpu.py"

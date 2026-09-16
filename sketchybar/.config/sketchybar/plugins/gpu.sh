#!/bin/sh

# GPU utilization (Apple Silicon), refreshed on a timer via update_freq.

PCT="$(ioreg -r -d 1 -c "IOAccelerator" | grep -o '"Device Utilization %"=[0-9]*' | head -1 | cut -d= -f2)"

if [ -z "$PCT" ]; then
  exit 0
fi

sketchybar --set "$NAME" icon="󰢮" label="${PCT}%"

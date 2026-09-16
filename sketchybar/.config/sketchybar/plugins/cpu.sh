#!/bin/sh

# CPU usage (user + sys), refreshed on a timer via update_freq in sketchybarrc.

CPU_LINE="$(top -l 1 -n 0 | grep "CPU usage")"
USER_PCT="$(echo "$CPU_LINE" | grep -Eo '[0-9.]+% user' | cut -d% -f1)"
SYS_PCT="$(echo "$CPU_LINE" | grep -Eo '[0-9.]+% sys' | cut -d% -f1)"

if [ -z "$USER_PCT" ] || [ -z "$SYS_PCT" ]; then
  exit 0
fi

TOTAL="$(echo "$USER_PCT $SYS_PCT" | awk '{printf "%.0f", $1 + $2}')"

sketchybar --set "$NAME" icon="󰻠" label="${TOTAL}%"

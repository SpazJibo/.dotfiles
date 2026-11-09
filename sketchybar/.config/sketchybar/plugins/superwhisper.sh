#!/bin/sh

# Superwhisper has no public live state file like voxtype did (no
# idle/recording/transcribing export), so this mirrors whether the app
# itself is running rather than live dictation state. If Superwhisper
# ever ships a state file/socket, swap this for a poll of that instead.

if pgrep -xq "superwhisper"; then
  # Hardcoded from the cyberpunk dusk palette in sketchybarrc -- plugin
  # scripts run as separate processes and do not inherit shell vars set there.
  ICON="" # nf-fa-microphone
  COLOR="0xff7a6a8f" # DIM (standby -- no live rec/transcribe signal available)
  LABEL=""
else
  ICON="" # nf-fa-microphone_slash
  COLOR="0xff44405a" # darker/inactive shade
  LABEL=""
fi

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="$LABEL" label.color="$COLOR"

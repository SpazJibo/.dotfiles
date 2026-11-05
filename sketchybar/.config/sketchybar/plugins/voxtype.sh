#!/bin/sh

# Polls voxtype's state file (/tmp/voxtype/state) and reflects the current
# dictation state (idle/recording/transcribing) in the bar. Voxtype writes
# this file itself whenever its state changes; see `voxtype config` ->
# [status]/state_file.

STATE_FILE="/tmp/voxtype/state"

STATE="idle"
[ -f "$STATE_FILE" ] && STATE="$(cat "$STATE_FILE" 2>/dev/null)"

# Hardcoded from the cyberpunk dusk palette in sketchybarrc — plugin
# scripts run as separate processes and don't inherit shell vars set there.
case "$STATE" in
  recording)
    ICON="" # nf-fa-microphone
    COLOR="0xff8855ff" # NEON_PURPLE
    LABEL="REC"
    ;;
  transcribing)
    ICON="" # nf-fa-hourglass_half
    COLOR="0xffcc44ee" # NEON_MAGENTA
    LABEL=""
    ;;
  *)
    ICON="" # nf-fa-microphone_slash (standby)
    COLOR="0xff7a6a8f" # DIM
    LABEL=""
    ;;
esac

sketchybar --set "$NAME" icon="$ICON" icon.color="$COLOR" label="$LABEL" label.color="$COLOR"

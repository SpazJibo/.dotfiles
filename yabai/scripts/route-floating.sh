#!/usr/bin/env sh
#
# Companion to launch-floating.sh (zero-flicker version): the rule set by
# launch-floating.sh already placed the new window on the right space at
# creation time, so this just has to focus the window — no space move,
# no space-focus call needed.
#
# Usage (from a yabai signal action): route-floating.sh "AppName" $YABAI_WINDOW_ID
#
set -eu

window_id="${2:-}"

if [ -n "$window_id" ]; then
    yabai -m window --focus "$window_id"
fi

#!/usr/bin/env sh
#
# Companion to launch-floating.sh: on a floating app's window_created
# signal, move the new window to the space that was focused right before
# launch, instead of leaving it wherever the catch-all rule placed it.
#
# Usage (from a yabai signal action): route-floating.sh "AppName" $YABAI_WINDOW_ID
#
set -eu

app_name="${1:?usage: route-floating.sh \"AppName\" window_id}"
window_id="${2:-}"
stash="/tmp/yabai-floating-target-space-${app_name}"

if [ -f "$stash" ]; then
    target_space=$(cat "$stash")
    rm -f "$stash"
else
    # Fallback (e.g. launched from Dock/Spotlight, not the skhd shortcut):
    # just leave it on whatever space is currently focused.
    target_space=$(yabai -m query --spaces --space | jq '.index')
fi

if [ -n "$window_id" ]; then
    yabai -m window "$window_id" --space "$target_space"
fi
yabai -m space --focus "$target_space"

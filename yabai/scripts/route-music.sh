#!/usr/bin/env sh
#
# Companion to launch-music-floating.sh: on Music's window_created signal,
# move the (floating) window to the space that was focused right before
# launch, instead of leaving it wherever the catch-all rule placed it.
#
# Invoked from a yabai `window_created` signal for Music (see .yabairc),
# which passes the new window's id as $1.
#
set -eu

window_id="${1:-}"
stash=/tmp/yabai-music-target-space

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

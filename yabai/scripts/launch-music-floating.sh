#!/usr/bin/env sh
#
# Launch Apple Music as a floating window on whatever space is currently
# focused — Music has a `manage=off` yabai rule (always floats) but the
# catch-all `app="^.*$" space=1` default rule would otherwise force every
# new window onto space 1 regardless of where it was launched from. Stash
# the currently-focused space here so the window_created signal
# (route-music.sh) can move the new window back to it after yabai's rule
# places it on space 1.
#
set -eu

cur_space=$(yabai -m query --spaces --space | jq '.index')
echo "$cur_space" > /tmp/yabai-music-target-space

open -a "Music"

#!/usr/bin/env sh
#
# Generic "launch <app> floating on whatever desktop I'm on" helper.
# Usage: launch-floating.sh "AppName"
#
# Stashes the currently-focused space to a per-app temp file so the
# matching window_created signal (route-floating.sh) can move the new
# window back there — needed because the catch-all `app="^.*$" space=1`
# yabai rule would otherwise force every new window onto Desktop 1
# regardless of where it was actually launched from.
#
set -eu

app_name="${1:?usage: launch-floating.sh \"AppName\"}"
stash="/tmp/yabai-floating-target-space-${app_name}"

cur_space=$(yabai -m query --spaces --space | jq '.index')
echo "$cur_space" > "$stash"

open -a "$app_name"

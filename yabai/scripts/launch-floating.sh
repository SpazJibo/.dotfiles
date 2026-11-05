#!/usr/bin/env sh
#
# Generic "launch <app> floating on whatever desktop I'm on" helper —
# zero-flicker version.
#
# Usage: launch-floating.sh "AppName"
#
# Earlier version stashed the current space and let a window_created
# signal MOVE the new window there after creation. That works, but the
# window is briefly created on Desktop 1 (via the catch-all
# `app="^.*$" space=1` rule) and behind whatever was already focused there,
# then relocated — visible as a "pops to back, then front" flicker.
#
# This version instead rewrites a labeled, app-specific yabai rule with
# the CURRENT space baked in as a literal number, right before launching.
# Since yabai rules are evaluated at window-creation time, the window gets
# placed directly on the right space to begin with — no post-creation
# move, no flicker. The matching window_created signal (route-floating.sh)
# then only needs to focus the window, not move it.
#
set -eu

app_name="${1:?usage: launch-floating.sh \"AppName\"}"
label="floating-dynamic-${app_name}"

cur_space=$(yabai -m query --spaces --space | jq '.index')

yabai -m rule --remove "$label" >/dev/null 2>&1 || true
yabai -m rule --add label="$label" app="^${app_name}\$" space="$cur_space" manage=off

open -a "$app_name"

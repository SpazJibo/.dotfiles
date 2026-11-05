#!/usr/bin/env sh
#
# Route Apple Notes to the right desktop depending on monitor setup:
#   - Kamvas Pro 19 attached -> first desktop (lowest space index) on that
#     display. Kamvas is the only external monitor in this setup, so
#     "a second yabai display exists" == Kamvas is attached.
#   - Kamvas not attached -> Desktop 4 on the main display.
#
# Invoked from a yabai `window_created` signal for Notes (see .yabairc),
# which passes the new window's id as $1.
#
set -eu

window_id="${1:-}"

display_count=$(yabai -m query --displays | jq 'length')

if [ "$display_count" -ge 2 ]; then
    # Kamvas attached: jump to the first space on the second display.
    target_space=$(yabai -m query --displays --display 2 | jq '.spaces[0]')
else
    target_space=4
fi

if [ -n "$window_id" ]; then
    yabai -m window "$window_id" --space "$target_space" || true
fi
# `space --focus` exits non-zero (harmlessly) when that space is already
# focused — don't let `set -e` abort the script before the window-focus
# step below runs.
yabai -m space --focus "$target_space" || true
if [ -n "$window_id" ]; then
    yabai -m window --focus "$window_id"
fi

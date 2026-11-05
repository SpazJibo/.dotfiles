#!/usr/bin/env sh
#
# Generic "focus follows new window" handler for apps WITHOUT their own
# dedicated window_created signal in .yabairc (Ghostty, Music, Podcasts,
# Obsidian, Notes all have their own — see that file). Bails out early for
# those so this doesn't race with their dedicated signal and snap focus
# back to wherever the catch-all `app="^.*$" space=1` rule initially placed
# the window (yabai's own regex engine has no negative-lookahead support,
# so the exclusion has to happen here in the action, not in the signal's
# `app=` match pattern).
#
set -eu

window_id="${1:?usage: generic-focus-follow.sh window_id}"
app=$(yabai -m query --windows --window "$window_id" | jq -r '.app')

case "$app" in
    Ghostty|Music|Podcasts|Obsidian|Notes)
        exit 0
        ;;
esac

target_space=$(yabai -m query --windows --window "$window_id" | jq '.space')
# `space --focus` exits non-zero (harmlessly) when that space is already
# focused — don't let `set -e` abort before the window-focus call below.
yabai -m space --focus "$target_space" || true
yabai -m window --focus "$window_id"

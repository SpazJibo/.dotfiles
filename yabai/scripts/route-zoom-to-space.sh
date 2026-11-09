#!/usr/bin/env sh
#
# Generic "move this window to <space>, focus it, and zoom-fullscreen it"
# handler — used for apps that should land zoomed-to-fill on a shared
# space (currently Ghostty and Rex Beta both target space 2).
#
# zoom-fullscreen fills the space but the window stays a normal
# tiled/floating window on that space — NOT macOS native fullscreen,
# which would pull it into its own Space. When two such apps share a
# space, whichever one is focused/zoomed visually covers the other;
# switching focus (e.g. via skhd launch) re-zooms the newly focused one.
#
# `window --space`, `space --focus`, `window --focus` and the zoom toggle
# are all asynchronous against the window server. Firing the next one
# before the previous has actually landed races it — observed symptom:
# the move succeeds, but an immediate `window --focus` or
# `--toggle zoom-fullscreen` right after silently snaps the window back
# to its old space even though the query API already reported the new
# one. Poll-confirm each step before moving to the next one; do not
# shorten these waits even though it makes cold launch feel slightly
# slower.
#
set -eu

window_id="${1:?usage: route-zoom-to-space.sh window_id space}"
space="${2:?usage: route-zoom-to-space.sh window_id space}"

wait_for() {
    # wait_for <jq_filter> <expected_value> — polls the window's current
    # state up to ~3s, returns success once it matches.
    filter="$1"
    expected="$2"
    i=0
    while [ "$i" -lt 10 ]; do
        current=$(yabai -m query --windows --window "$window_id" 2>/dev/null | jq -r "$filter // empty")
        [ "$current" = "$expected" ] && return 0
        sleep 0.3
        i=$((i + 1))
    done
    return 1
}

yabai -m window "$window_id" --space "$space" || true
wait_for '.space' "$space" || true

# `space --focus` exits non-zero (harmlessly) when that space is already
# focused — don't let `set -e` abort before the later calls.
yabai -m space --focus "$space" || true
sleep 0.5

yabai -m window --focus "$window_id" || true
wait_for '.space' "$space" || true

yabai -m window --toggle zoom-fullscreen || true

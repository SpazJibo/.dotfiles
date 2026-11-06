#!/usr/bin/env sh
#
# Rex Beta: lands on Desktop 4 and fills it via yabai zoom-fullscreen
# (fills the space, stays a normal tiled/floating window on that space —
# NOT macOS native fullscreen, which would pull it into its own Space).
#
# `window --space`, `space --focus`, `window --focus` and the zoom toggle
# are all asynchronous against the window server. Firing the next one
# before the previous has actually landed races it — observed symptom:
# the move to space 4 succeeds, but an immediate `window --focus` or
# `--toggle zoom-fullscreen` right after silently snaps the window back
# to its old space even though the query API already reported space 4.
# Poll-confirm each step before moving to the next one; do not shorten
# these waits even though it makes cold launch feel slightly slower.
#
set -eu

window_id="${1:?usage: route-rex.sh window_id}"

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

yabai -m window "$window_id" --space 4 || true
wait_for '.space' '4' || true

# `space --focus` exits non-zero (harmlessly) when that space is already
# focused — don't let `set -e` abort before the later calls.
yabai -m space --focus 4 || true
sleep 0.5

yabai -m window --focus "$window_id" || true
wait_for '.space' '4' || true

yabai -m window --toggle zoom-fullscreen || true

#!/bin/sh

# Apple Music now-playing widget. Polls Music.app directly via AppleScript
# (avoids relying on the private MediaRemote framework that backs
# sketchybar's built-in media_change event, which has been flaky on recent
# macOS). Shows nothing if Music isn't running or nothing is playing.

RUNNING="$(osascript -e 'application "Music" is running' 2>/dev/null)"

if [ "$RUNNING" != "true" ]; then
  sketchybar --set "$NAME" label="" icon.drawing=off label.drawing=off
  exit 0
fi

STATE="$(osascript -e 'tell application "Music" to player state as string' 2>/dev/null)"

if [ "$STATE" != "playing" ]; then
  sketchybar --set "$NAME" label="" icon.drawing=off label.drawing=off
  exit 0
fi

TRACK="$(osascript -e 'tell application "Music" to name of current track' 2>/dev/null)"
ARTIST="$(osascript -e 'tell application "Music" to artist of current track' 2>/dev/null)"

if [ -z "$TRACK" ]; then
  sketchybar --set "$NAME" label="" icon.drawing=off label.drawing=off
  exit 0
fi

LABEL="$ARTIST - $TRACK"
# Truncate long labels so the bar doesn't get crowded
MAXLEN=40
if [ ${#LABEL} -gt $MAXLEN ]; then
  LABEL="$(echo "$LABEL" | cut -c1-$MAXLEN)…"
fi

sketchybar --set "$NAME" icon.drawing=on label.drawing=on icon="" label="$LABEL"

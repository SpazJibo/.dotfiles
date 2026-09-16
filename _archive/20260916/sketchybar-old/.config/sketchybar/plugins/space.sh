#!/bin/sh

# Cyberpunk glow: selected space gets a bright magenta pill w/ cyan border,
# unselected spaces stay dim outlines.

NEON_CYAN=0xff00fff2
NEON_MAGENTA=0xffff00c8
ITEM_BG_SELECTED=0x40ff00c8
ITEM_BG_IDLE=0x1500fff2

if [ "$SELECTED" = "true" ]; then
  sketchybar --set "$NAME" background.drawing=on \
                            background.color="$ITEM_BG_SELECTED" \
                            background.border_color="$NEON_MAGENTA" \
                            icon.color="$NEON_MAGENTA"
else
  sketchybar --set "$NAME" background.drawing=on \
                            background.color="$ITEM_BG_IDLE" \
                            background.border_color="$NEON_CYAN" \
                            icon.color="$NEON_CYAN"
fi

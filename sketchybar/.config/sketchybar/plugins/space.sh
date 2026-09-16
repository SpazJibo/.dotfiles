#!/bin/sh

# Cyberpunk dusk glow: selected space gets a bright violet pill w/ red border,
# unselected spaces stay dim outlines.

NEON_CYAN=0xffff3355
NEON_MAGENTA=0xffcc44ee
ITEM_BG_SELECTED=0x40cc44ee
ITEM_BG_IDLE=0x15ff3355

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

#!/bin/sh

# Weather via wttr.in (no API key). Refreshed on a timer via update_freq.

WEATHER="$(curl -s --max-time 5 "wttr.in/?format=%C+%t")"

if [ -z "$WEATHER" ]; then
  exit 0
fi

CONDITION="$(echo "$WEATHER" | sed -E 's/ *[+-][0-9]+.*//')"
TEMP="$(echo "$WEATHER" | grep -Eo '[+-][0-9]+°[FC]' | tr -d '+')"

case "$(echo "$CONDITION" | tr '[:upper:]' '[:lower:]')" in
  *thunder*|*storm*) ICON="󰖓" ;;
  *snow*|*sleet*|*ice*) ICON="󰖘" ;;
  *rain*|*drizzle*|*shower*) ICON="󰖗" ;;
  *fog*|*mist*|*haze*) ICON="󰖑" ;;
  *cloud*|*overcast*) ICON="󰖐" ;;
  *clear*|*sunny*) ICON="" ;;
  *) ICON="󰖐" ;;
esac

sketchybar --set "$NAME" icon="$ICON" label="$TEMP"

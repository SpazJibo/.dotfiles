-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 1
local omarchy_monitor_scale = 1.25

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- LG above the Kamvas; built-in display to the Kamvas's right.
-- Coordinates are logical pixels at scale 1; keep each display's preferred mode.
hl.monitor({ output = "DP-7", mode = "preferred", position = "0x0", scale = 1 })
hl.monitor({ output = "DP-6", mode = "preferred", position = "0x2160", scale = 1 })
hl.monitor({ output = "eDP-1", mode = "preferred", position = "3840x2160", scale = 1 })

-- In this docked layout, odd workspaces belong on the LG and even ones on
-- the Kamvas. Make 1 and 2 the respective default workspaces.
for workspace = 1, 10 do
  local rule = {
    workspace = tostring(workspace),
    monitor = workspace % 2 == 1 and "DP-7" or "DP-6",
  }
  if workspace <= 2 then rule.default = true end
  hl.workspace_rule(rule)
end

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })

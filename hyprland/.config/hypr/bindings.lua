-- Keep only your personal keybinding overrides here. Add new bindings or
-- unbind defaults before replacing them.

-- See current bindings and descriptions:
--   omarchy menu keybindings --print

-- To disable every Omarchy default binding, set this in
-- ~/.config/hypr/hyprland.lua before require("default.hypr.omarchy"), then add
-- only the bindings you want below:
--   omarchy_default_bindings = false

-- To disable all preinstalled app/webapp bindings, set:
--   omarchy_preinstalled_bindings = false

-- Add a new binding.
-- o.bind("SUPER + SHIFT + R", "SSH", "alacritty -e ssh your-server")

-- Change an existing binding by unbinding it first, then binding the key again.
-- This example changes SUPER+SPACE from the launcher to the Omarchy root menu.
-- hl.unbind("SUPER + SPACE")
-- o.bind("SUPER + SPACE", "Omarchy menu", "omarchy-menu toggle root")

-- Disable a default binding without replacing it.
-- hl.unbind("SUPER + SHIFT + B")

-- Logitech MX Keys examples:
-- o.bind("SUPER + SHIFT + S", nil, "omarchy-capture-screenshot")
-- o.bind("SUPER + H", nil, "voxtype record toggle")
-- o.bind("SUPER + PERIOD", nil, "omarchy-shell shell toggle omarchy.emojis")

-- Override Omarchy's generic terminal launcher (which follows xdg-terminal-exec).
hl.unbind("SUPER + RETURN")
o.bind("SUPER + RETURN", "Ghostty", { launch = "ghostty" })

-- Omarchy 4.0.4's `SUPER + code:N` workspace bindings show an empty key in
-- Hyprland 0.56's live bind table. Replace them with named number keys so
-- holding Super cannot accidentally match a blank numbered-workspace bind.
-- Preserve the original 1-9, 0=10 and shift/alt move behavior.
for workspace = 1, 10 do
  local code = "code:" .. tostring(workspace + 9)
  local digit = workspace == 10 and "0" or tostring(workspace)
  hl.unbind("SUPER + " .. code)
  hl.unbind("SUPER + SHIFT + " .. code)
  hl.unbind("SUPER + SHIFT + ALT + " .. code)
  o.bind("SUPER + " .. digit, "Switch to workspace " .. workspace,
    hl.dsp.focus({ workspace = tostring(workspace) }))
  o.bind("SUPER + SHIFT + " .. digit, "Move window to workspace " .. workspace,
    hl.dsp.window.move({ workspace = tostring(workspace) }))
  o.bind("SUPER + SHIFT + ALT + " .. digit, "Move window silently to workspace " .. workspace,
    hl.dsp.window.move({ workspace = tostring(workspace), follow = false }))
end


-- Options include 'blue', 'darkblue', 'default', 'delek', 'desert', 'elflord', 'evening', 'habamax', 'industry', 'kohler', 'lunaperche', 
-- 'morning', 'murphy', 'pablo', 'peachpuff', 'quiet', 'ron',  'shades_of_purple', 'shine', 'slate', 'torte', 'zellner'   
local colorscheme = "catppuccin-mocha"

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found!")
  return
end

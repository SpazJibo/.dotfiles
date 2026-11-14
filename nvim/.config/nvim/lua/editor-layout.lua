-- Soft wrapping and a small, toggleable margin without changing buffer text.
local M = {}
local padding = 4

local function margin()
  return math.min(padding, math.floor((vim.o.columns - 1) / 2))
end

function M.enable()
  if vim.bo.buftype ~= '' or vim.api.nvim_win_get_config(0).relative ~= '' then return end
  local zen = require('snacks').zen
  if zen.win and zen.win:valid() then return end
  zen({
    toggles = {}, -- Keep diagnostics, signs, and other editor features as configured.
    center = false,
    show = { statusline = true, tabline = true },
    win = {
      width = function() return math.max(1, vim.o.columns - 2 * margin()) end,
      col = margin,
      backdrop = { transparent = false, blend = 0 },
      wo = { wrap = true, linebreak = true, breakindent = true },
    },
  })
end

function M.toggle()
  local zen = require('snacks').zen
  if zen.win and zen.win:valid() then
    zen()
  else
    M.enable()
  end
end

local function enable_single_window()
  local windows = vim.tbl_filter(function(win)
    return vim.api.nvim_win_get_config(win).relative == ''
  end, vim.api.nvim_tabpage_list_wins(0))
  -- Respect layouts intentionally opened with splits, such as nvim -O file1 file2.
  if #windows == 1 then M.enable() end
end

function M.setup()
  vim.opt.wrap = true
  vim.opt.linebreak = true
  vim.opt.breakindent = true
  vim.api.nvim_create_user_command('TogglePadding', M.toggle, {
    force = true,
    desc = 'Toggle four-column left/right editing margins',
  })
  vim.api.nvim_create_autocmd('VimEnter', {
    group = vim.api.nvim_create_augroup('editor-layout', { clear = true }),
    callback = function() vim.schedule(enable_single_window) end,
  })
  if vim.v.vim_did_enter == 1 then enable_single_window() end
end

M.setup()
return M

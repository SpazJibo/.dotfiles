-- Run: nvim --headless -u NONE -l nvim/.config/nvim/tests/editor-layout.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
vim.opt.runtimepath:prepend(root)
local snacks = vim.fn.globpath(vim.fn.stdpath('data') .. '/site/pack', '**/snacks.nvim', false, true)[1]
assert(snacks, 'Install the configured Snacks plugin before running this test')
vim.opt.runtimepath:prepend(snacks)
require('snacks').setup({})
vim.o.columns = 80
vim.o.lines = 24
vim.o.number = true
vim.o.relativenumber = true
local buf = vim.api.nvim_get_current_buf()
local parent = vim.api.nvim_get_current_win()
local lines = {'header', string.rep('alpha beta gamma delta ', 12), 'middle', 'tail'}
vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
local loaded, layout = pcall(require, 'editor-layout')
assert(loaded, 'Editor layout configuration must exist: ' .. tostring(layout))
assert(vim.o.wrap and vim.o.linebreak and vim.o.breakindent, 'Soft wrapping must use word boundaries and preserve indentation')
layout.enable()
local padded = vim.api.nvim_get_current_win()
local config = vim.api.nvim_win_get_config(padded)
assert(config.relative == 'editor', 'Padding must use a centered editing view')
assert(config.width == 72 and config.col == 4, 'Expected four empty columns on each side: ' .. vim.inspect(config))
assert(vim.api.nvim_win_get_buf(padded) == buf, 'The padded view must use the original buffer')
assert(vim.wo.number and vim.wo.relativenumber, 'Keep existing line numbers')
assert(vim.wo.wrap and vim.wo.linebreak, 'The padded window must preserve word wrapping')
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(buf, 0, -1, false), lines), 'Padding/wrapping must not alter saved text')
layout.enable()
assert(vim.api.nvim_get_current_win() == padded, 'Enabling twice must be idempotent')
layout.toggle()
assert(not vim.api.nvim_win_is_valid(padded), 'Toggling must close the padded view')
assert(vim.api.nvim_get_current_win() == parent, 'Toggling must restore the original window')
layout.toggle()
vim.o.columns = 100
vim.api.nvim_exec_autocmds('VimResized', {})
assert(vim.wait(500, function()
  return vim.api.nvim_win_get_config(vim.api.nvim_get_current_win()).width == 92
end), 'Padding must resize with the terminal')
config = vim.api.nvim_win_get_config(vim.api.nvim_get_current_win())
assert(config.col == 4, 'Resizing must retain equal margins')
-- Loading the file again is the user-facing reload operation.
dofile(root .. '/lua/editor-layout.lua')
assert(vim.fn.exists(':TogglePadding') == 2, 'Reload must retain the toggle command')
layout.toggle()
assert(vim.deep_equal(vim.api.nvim_buf_get_lines(buf, 0, -1, false), lines), 'Reload/toggle must preserve text')
vim.bo.buftype = 'nofile'
layout.enable()
assert(vim.api.nvim_get_current_win() == parent, 'Do not pad special buffers')
print('PASS: word wrapping, equal padding, line numbers, resizing, toggle, reload, and unchanged text')
vim.cmd('qa!')

-- Run: nvim --headless -u NONE -l nvim/.config/nvim/tests/wrapped-motion.lua
local root = vim.fn.fnamemodify(debug.getinfo(1, 'S').source:sub(2), ':p:h:h')
local keymaps = root .. '/lua/keymaps.lua'
dofile(keymaps)
vim.o.columns = 40
vim.o.lines = 20
vim.wo.wrap = true
vim.wo.number = false
vim.wo.relativenumber = false
vim.wo.signcolumn = 'no'
vim.wo.foldcolumn = '0'
vim.api.nvim_buf_set_lines(0, 0, -1, false, {'header', string.rep('x', 160), 'middle', 'tail'})
local function keys(text)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(text, true, false, true), 'xt', false)
end
local function cursor() return vim.api.nvim_win_get_cursor(0) end
vim.api.nvim_win_set_cursor(0, {2, 90})
keys('k')
local up = cursor()
assert(up[1] == 2 and up[2] < 90, 'k must move up one wrapped row: ' .. vim.inspect(up))
keys('j')
assert(vim.deep_equal(cursor(), {2, 90}), 'j must return down one wrapped row')
vim.api.nvim_win_set_cursor(0, {4, 0})
keys('2k')
assert(cursor()[1] == 2, '2k must retain buffer-line movement')
keys('2j')
assert(cursor()[1] == 4, '2j must retain buffer-line movement')
vim.api.nvim_win_set_cursor(0, {2, 90})
keys('vk')
local visual_up = cursor()
assert(visual_up[1] == 2 and visual_up[2] < 90, 'Visual k must move through wrapped rows')
keys('<Esc>')
assert(vim.fn.maparg('k', 'o') == '', 'Operator-pending k must not be remapped')
dofile(keymaps)
vim.api.nvim_win_set_cursor(0, {2, 90})
keys('k')
assert(cursor()[1] == 2 and cursor()[2] < 90, 'Reload must retain the mapping')
print('PASS: wrapped j/k, counted motions, visual mode, operator mappings, and reload')
vim.cmd('qa!')

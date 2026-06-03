-- Set leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Enable global Nerd Font Support
vim.g.have_nerd_font = true

-- Relative line numbers
vim.o.relativenumber = true
vim.o.number = true

vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.autoindent = true

-- Case insenstivity searching
vim.o.ignorecase = true
vim.o.smartcase = true

-- Sync clipboards
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Raide dialog if unsaved buffer
vim.o.confirm = true

-- Snappy escape
vim.o.ttimeoutlen = 1

-- Vim diagnostics
vim.diagnostic.config({
	severity_sort = true,
	update_in_insert = false,
	float = {source = 'if_many' },
	jump = {float = true},
})

vim.api.nvim_create_autocmd('TextYankPost', {
	group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
	callback = function() vim.highlight.on_yank() end
})

require('keymaps')
require('plugins')
require('theme')
require('lsp')

vim.cmd('syntax off')
vim.api.nvim_create_autocmd('FileType', {
	callback = function() pcall(vim.treesitter.start) end,
})


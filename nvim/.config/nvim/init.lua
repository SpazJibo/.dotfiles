-- Set leader
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Relative line numbers
vim.o.relativenumber = true
vim.o.number = true

-- Case insenstivie searching
vim.o.ignorecase = true
vim.o.smartcase = true

-- Sync clipboards
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- Raise dialog if unsaved buffer
vim.o.confirm = true

-- True color support (needed for tokyonight + transparency)
vim.o.termguicolors = true

-- Snappy escape
-- vim.o.timeoutlen = 1

-- Vim diagnostics
vim.diagnostic.config({
	severity_sort = true,
	update_in_insert = false,
	float = {source = 'if_any'},
	jump = {float = true },
})

require('keymaps')
require('autocmds')
require('vimpack')
require('colorscheme')
require('telescope')
require('oil-config')
require('lsp')
require('smear-cursor-config')
require('markdown-preview-config')

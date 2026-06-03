vim.lsp.enable({
  'lua_ls',
  'ty'
})

vim.o.signcolumn = 'yes'
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })

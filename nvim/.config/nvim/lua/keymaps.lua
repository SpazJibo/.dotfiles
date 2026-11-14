-- Show diagnostics
vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, {desc = 'show diagnostics'})

-- Move through wrapped screen rows; counts still move by file lines.
vim.keymap.set({ 'n', 'x' }, 'j', function()
  return vim.v.count == 0 and 'gj' or 'j'
end, { expr = true, silent = true, desc = 'Move down a display line' })
vim.keymap.set({ 'n', 'x' }, 'k', function()
  return vim.v.count == 0 and 'gk' or 'k'
end, { expr = true, silent = true, desc = 'Move up a display line' })

-- Easily move between windows
vim.keymap.set('n', '<C-h>', '<C-w>h', { silent = true, desc = 'Move focus to the left window'})
vim.keymap.set('n', '<C-l>', '<C-w>l', { silent = true, desc = 'Move focus to the right window'})
vim.keymap.set('n', '<C-j>', '<C-w>j', { silent = true, desc = 'Move focus to the lower window'})
vim.keymap.set('n', '<C-k>', '<C-w>k', { silent = true, desc = 'Move focus to the upper window'})

-- Quickfix list: jump to selection and close the list in one step
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('qf-close-on-select', { clear = true }),
  pattern = 'qf',
  callback = function(event)
    vim.keymap.set('n', '<CR>', '<CR>:cclose<CR>', {
      buffer = event.buf,
      silent = true,
      desc = 'Jump to quickfix entry and close the list',
    })
  end,
})

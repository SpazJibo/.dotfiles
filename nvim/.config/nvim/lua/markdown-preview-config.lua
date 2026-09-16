-- Configs Specific to markdown-preview.nvim
-- Opens a live-reloading markdown preview in your default browser.

vim.g.mkdp_auto_close = 1        -- close the preview tab when the markdown buffer closes
vim.g.mkdp_refresh_slow = 0      -- refresh on every change, not just on write
vim.g.mkdp_theme = 'dark'        -- matches a dark colorscheme (tokyonight)

-- The plugin's commands (MarkdownPreview/Stop/Toggle) are buffer-local and
-- only exist on markdown buffers, so the keymap must be scoped the same way.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('markdown-preview-config', { clear = true }),
  pattern = 'markdown',
  callback = function(event)
    vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreviewToggle<CR>', {
      buffer = event.buf,
      desc = 'Toggle markdown preview in browser',
    })
  end,
})

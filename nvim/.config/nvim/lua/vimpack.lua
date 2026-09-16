-- Plugins
vim.pack.add({ 
  { src = "https://github.com/nvim-lua/plenary.nvim" }, 
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  { src = "https://github.com/folke/tokyonight.nvim" },
  { src = "https://github.com/stevearc/oil.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/neovim/nvim-lspconfig" },
  { src = "https://github.com/sphamba/smear-cursor.nvim" },
  { src = "https://github.com/iamcco/markdown-preview.nvim" },
})

-- markdown-preview.nvim ships no vim.pack build hook (that's a lazy.nvim-only
-- feature), so run its own installer once after vim.pack fetches/updates it.
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('markdown-preview-install', { clear = true }),
  callback = function(event)
    if event.data and event.data.spec and event.data.spec.name == 'markdown-preview.nvim'
      and (event.data.kind == 'install' or event.data.kind == 'update') then
      vim.fn['mkdp#util#install']()
    end
  end,
})


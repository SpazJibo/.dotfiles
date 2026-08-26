require('tokyonight').setup({
  transparent = true, -- disable setting background color
  styles = {
    sidebars = 'transparent',
    floats = 'transparent',
  },
})

vim.cmd.colorscheme('tokyonight')

-- Belt-and-braces: clear any background tokyonight/plugins might still set
-- (relevant if your terminal emulator itself is transparent).
vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalNC', { bg = 'none' })
vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'none' })
vim.api.nvim_set_hl(0, 'SignColumn', { bg = 'none' })
vim.api.nvim_set_hl(0, 'EndOfBuffer', { bg = 'none' })

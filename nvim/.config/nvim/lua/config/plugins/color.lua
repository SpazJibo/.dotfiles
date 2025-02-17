return {
  {
    "folke/tokyonight.nvim",
    config = function() vim.cmd.colorscheme "tokyonight" end,
    opts = {
      transparent = true,
      style = {
        sidebars = "transparent",
        floats = "transparent",
      }
    }
  },
}

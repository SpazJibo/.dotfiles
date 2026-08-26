-- Configs Specific to oil
local oil = require('oil')
oil.setup({
  columns = { 'icon' },
})

vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory (Oil)' })

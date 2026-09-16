-- Configs Specific to oil
local oil = require('oil')
oil.setup({
  columns = { 'icon' },
  watch_for_changes = true
})

vim.keymap.set('n', '-', '<CMD>Oil<CR>', { desc = 'Open parent directory (Oil)' })

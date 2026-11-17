-- Vault-wide Tasks queries; dashboard results stay out of the saved Markdown.
require('obsidian-tasks').setup({})

local function open_dashboard()
  local path = vim.fn.expand('~/Documents/SpazVault/Task Dashboard.md')
  vim.cmd.edit(vim.fn.fnameescape(path))
end

vim.api.nvim_create_user_command('Tasks', open_dashboard, {
  desc = 'Open SpazVault task dashboard', force = true,
})
vim.keymap.set('n', '<leader>ot', open_dashboard, { desc = 'Obsidian task dashboard' })

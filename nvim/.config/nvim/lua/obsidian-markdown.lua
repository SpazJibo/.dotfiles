-- Obsidian commands + native LSP in vaults; Markdown Oxide remains for other Markdown.
local vault = vim.fn.expand('~/Documents/SpazVault')
local group = vim.api.nvim_create_augroup('spazarchy-markdown', { clear = true })

vim.api.nvim_create_autocmd('LspAttach', {
  group = group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client or client.name ~= 'obsidian-ls' then return end
    vim.bo[ev.buf].completeopt = 'menuone,noselect,fuzzy,nosort'
    vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    vim.api.nvim_buf_create_user_command(ev.buf, 'Daily', function()
      vim.cmd('Obsidian today')
    end, { desc = 'Open today\'s Obsidian daily note' })
  end,
})

require('obsidian').setup({
  legacy_commands = false,
  workspaces = { { name = 'SpazVault', path = vault } },
  picker = { name = 'telescope.nvim' },
  templates = { folder = 'zTemplates' },
  daily_notes = { folder = 'Daily Notes', template = 'Daily Note.md' },
  -- Never rewrite existing notes' frontmatter just because they were saved.
  frontmatter = { enabled = false },
  note_id_func = function(title)
    assert(title and title:match('%S'), 'Give the new note a title')
    return title:gsub('[/\\]', '-')
  end,
  ui = { enable = false }, -- render-markdown owns the in-buffer rendering.
  footer = { enabled = false },
  checkbox = { enabled = true, create_new = true, order = { ' ', 'x' } },
  callbacks = {
    enter_note = function()
      local opts = { buffer = true, silent = true }
      vim.keymap.set({ 'n', 'x' }, '<leader>x', '<cmd>Obsidian toggle_checkbox<CR>',
        vim.tbl_extend('force', opts, { desc = 'Create/toggle checkbox' }))
      vim.keymap.set('n', '<leader>os', '<cmd>Obsidian quick_switch<CR>',
        vim.tbl_extend('force', opts, { desc = 'Obsidian find note' }))
      vim.keymap.set('n', '<leader>of', '<cmd>Obsidian search<CR>',
        vim.tbl_extend('force', opts, { desc = 'Obsidian search contents' }))
      vim.keymap.set('n', '<leader>ob', '<cmd>Obsidian backlinks<CR>',
        vim.tbl_extend('force', opts, { desc = 'Obsidian backlinks' }))
      vim.keymap.set('n', '<leader>od', '<cmd>Obsidian today<CR>',
        vim.tbl_extend('force', opts, { desc = 'Obsidian today' }))
    end,
  },
})

require('render-markdown').setup({})
require('snacks').setup({
  image = {
    enabled = true,
    -- A fallback float is used if the terminal lacks Unicode placeholders.
    doc = { enabled = true, inline = true, float = true },
    resolve = function(file, src)
      -- Never fetch remote image URLs automatically while editing private notes.
      if src:match('^https?://') then return '/nonexistent/remote-image-disabled' end
      local clean = src:gsub('|.*$', '')
      local local_path = vim.fs.joinpath(vim.fs.dirname(file), clean)
      if vim.uv.fs_stat(local_path) then return local_path end
      if file:sub(1, #vault + 1) == vault .. '/' then
        local root_path = vim.fs.joinpath(vault, clean:gsub('^/', ''))
        if vim.uv.fs_stat(root_path) then return root_path end
        local matches = vim.fs.find(vim.fs.basename(clean), { path = vault, type = 'file', limit = 2 })
        if #matches == 1 then return matches[1] end
      end
    end,
  },
})

vim.api.nvim_create_autocmd('FileType', {
  group = group,
  pattern = 'markdown',
  callback = function(ev)
    vim.wo.spell = true
    vim.bo[ev.buf].spelllang = 'en_us'
    vim.wo.conceallevel = 2
    local ok, err = pcall(vim.treesitter.start, ev.buf)
    if not ok then vim.notify('Markdown parser: ' .. tostring(err), vim.log.levels.WARN) end
  end,
})

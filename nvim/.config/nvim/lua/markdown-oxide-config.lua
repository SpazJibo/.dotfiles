-- Markdown Oxide: native Neovim LSP/completion, no extra plugin manager.
vim.lsp.config('markdown_oxide', {
  cmd = { vim.fn.expand('~/.local/bin/markdown-oxide') },
  -- Prefer the vault marker over a nested Git repository.
  root_markers = { '.obsidian', '.moxide.toml', '.git' },
  root_dir = function(bufnr, on_dir)
    local file = vim.api.nvim_buf_get_name(bufnr)
    -- obsidian.nvim provides the vault LSP; avoid duplicate completions/jumps.
    if vim.fs.root(file, '.obsidian') then return end
    on_dir(vim.fs.root(file, { '.moxide.toml', '.git' }) or vim.fs.dirname(file))
  end,
  capabilities = {
    workspace = { didChangeWatchedFiles = { dynamicRegistration = true } },
  },
})

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('markdown-oxide-attach', { clear = true }),
  callback = function(event)
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if not client or client.name ~= 'markdown_oxide' then return end
    -- Ctrl-X Ctrl-O manually requests completion; advertised triggers also work.
    vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
    vim.api.nvim_buf_create_user_command(event.buf, 'Daily', function(args)
      client:exec_cmd({
        title = 'Open daily note', command = 'jump',
        arguments = { args.args ~= '' and args.args or 'today' },
      }, { bufnr = event.buf })
    end, { desc = 'Open Markdown Oxide daily note', nargs = '*' })
  end,
})

vim.lsp.enable('markdown_oxide')

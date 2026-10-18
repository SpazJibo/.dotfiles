-- Configs Specific to LSP (using nvim-lspconfig's bundled server configs)
-- No mason: each server binary is expected to already be on $PATH.
--   roslyn_ls      -> dotnet tool install --global roslyn-language-server --prerelease \
--                       --source https://pkgs.dev.azure.com/azure-public/vside/_packaging/vs-impl/nuget/v3/index.json
--   ts_ls          -> npm install -g typescript typescript-language-server
--   gopls          -> brew install gopls (or `go install golang.org/x/tools/gopls@latest`)
--   rust_analyzer  -> rustup component add rust-analyzer
--   basedpyright   -> brew install basedpyright
--   lua_ls         -> brew install lua-language-server

-- roslyn-language-server's own apphost (the plain `roslyn-language-server`
-- binary) fails to resolve the .NET runtime under Homebrew's split
-- bin/libexec dotnet layout (it always reports DOTNET_ROOT as the "bin"
-- shim directory, ignoring what we set, and exits 131 "You must install
-- .NET"). Sidestep it entirely by invoking the server's .dll via `dotnet
-- exec`, which uses dotnet's own (working) runtime resolution instead.
do
  local roslyn_dll = vim.fn.glob(
    vim.fn.expand('~/.dotnet/tools/.store/roslyn-language-server/*/roslyn-language-server.osx-arm64/*/tools/net10.0/osx-arm64/Microsoft.CodeAnalysis.LanguageServer.dll'),
    false,
    true
  )[1]
  if roslyn_dll then
    vim.lsp.config('roslyn_ls', {
      cmd = {
        'dotnet',
        'exec',
        roslyn_dll,
        '--logLevel',
        'Information',
        '--extensionLogDirectory',
        vim.fs.joinpath(vim.uv.os_tmpdir(), 'roslyn_ls/logs'),
        '--stdio',
      },
    })
  else
    -- Global .NET tools may not be on PATH in desktop-launched terminals.
    local roslyn_tool = vim.fn.expand('~/.dotnet/tools/roslyn-language-server')
    if vim.fn.executable(roslyn_tool) == 1 then
      vim.lsp.config('roslyn_ls', {
        cmd = {
          roslyn_tool,
          '--logLevel',
          'Information',
          '--extensionLogDirectory',
          vim.fs.joinpath(vim.uv.os_tmpdir(), 'roslyn_ls/logs'),
          '--stdio',
        },
      })
    end
  end
end

-- Teach lua_ls about Neovim's `vim` global + runtime API so it stops
-- warning about "undefined global `vim`" when editing this config.
-- Skipped for any Lua project that already ships its own .luarc.json.
vim.lsp.config('lua_ls', {
  on_init = function(client)
    local path = client.workspace_folders and client.workspace_folders[1].name
    if path and path ~= vim.fn.stdpath('config') and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then
      return
    end

    client.config.settings = vim.tbl_deep_extend('force', client.config.settings, {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = { globals = { 'vim' } },
        workspace = {
          checkThirdParty = false,
          library = { vim.env.VIMRUNTIME },
        },
      },
    })
  end,
})

vim.lsp.enable({
  'roslyn_ls',
  'ts_ls',
  'gopls',
  'rust_analyzer',
  'basedpyright',
  'lua_ls',
})

-- Buffer-local keymaps, set only once a language server actually attaches
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
  callback = function(event)
    local opts = { buffer = event.buf }

    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, vim.tbl_extend('force', opts, { desc = 'Goto definition' }))
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, vim.tbl_extend('force', opts, { desc = 'Goto declaration' }))
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, vim.tbl_extend('force', opts, { desc = 'Goto references' }))
    vim.keymap.set('n', 'gI', vim.lsp.buf.implementation, vim.tbl_extend('force', opts, { desc = 'Goto implementation' }))
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, vim.tbl_extend('force', opts, { desc = 'Hover documentation' }))
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, vim.tbl_extend('force', opts, { desc = 'LSP rename' }))
    vim.keymap.set(
      { 'n', 'v' },
      '<leader>ca',
      vim.lsp.buf.code_action,
      vim.tbl_extend('force', opts, { desc = 'LSP code action' })
    )
  end,
})

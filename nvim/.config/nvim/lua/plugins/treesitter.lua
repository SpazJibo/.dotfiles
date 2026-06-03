-- Tree-Sitter Configuration
local function setup_treesitter()
    local treesitter = {
        get_installed = function()
            return vim.treesitter.get_installations()
        end
    }
    
    local group = vim.api.nvim_create_augroup("TreeSitter", { clear = true })
    
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
            if vim.list_contains(treesitter.get_installed(), vim.treesitter.language.get_lang(args.match)) then
                vim.treesitter.start(args.buf)
            end
        end,
    })
end

setup_treesitter()

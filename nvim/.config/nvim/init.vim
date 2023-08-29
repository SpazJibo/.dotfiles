set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
set relativenumber
set nu
set nohlsearch
set hidden
set noerrorbells
set nowrap
set nobackup
set undodir=~/.vim/undodir
set undofile
set incsearch
set scrolloff=8
set colorcolumn=80
set signcolumn=yes

call plug#begin('~/.vim/plugged')
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'rebelot/kanagawa.nvim'
Plug 'jiangmiao/auto-pairs'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'iamcco/markdown-preview.nvim'
Plug 'evanleck/vim-svelte', {'branch': 'main'}
call plug#end()

colorscheme kanagawa 
highlight Normal guibg=NONE ctermbg=NONE

let mapleader = " "
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<c-b>"
let g:UltiSnipsJumpBackwardTrigger="<c-z"
let g:UtilSnipEditSplit="vertical"

nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fe <cmd>lua require 'telescope'.extensions.file_browser.file_browser()<cr>

inoremap <c-s> <Esc>:MarkdownPreview<cr>
nnoremap <c-s> <Esc>:MarkdownPreview<cr>

inoremap <M-s> <Esc>:MarkdownPreviewStop<cr>
nnoremap <M-s> <Esc>:MarkdownPreviewStop<cr>

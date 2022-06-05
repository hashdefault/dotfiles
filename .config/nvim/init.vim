:set number
:set autoindent
:set tabstop=4
:set shiftwidth=4
:set smarttab
:set softtabstop=4
:set encoding=UTF-8
syntax on

call plug#begin()
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'ryanoasis/vim-devicons'
Plug 'neovim/nvim-lspconfig'
"Plug 'leafOfTree/vim-vue-plugin'"
Plug 'edkolev/tmuxline.vim'
Plug 'junegunn/fzf.vim'
Plug 'vim-airline/vim-airline'
Plug 'preservim/nerdtree'
Plug 'tpope/vim-surround'
Plug 'mattn/emmet-vim'
Plug 'flazz/vim-colorschemes'
Plug 'sainnhe/everforest'
call plug#end()


"alias to nerdtreetoggle"
nnoremap <c-t> :NERDTreeToggle<cr>
nnoremap <c-f> :NERDTreeFocus<cr>

colorscheme everforest 


" trigger to autocomplete "
let g:ycm_auto_trigger = 1

"transparent background"
hi Normal guibg=NONE ctermbg=NONE


lua <<EOF
require('nvim-treesitter.configs').setup {
  ensure_installed = "all",
  highlight = { enable = true },
  indent = { enable = true }
}
EOF
"let g:vim_vue_plugin_config = { 
"    \'syntax': {
"    \   'template': ['html'],
"    \   'script': ['javascript', 'typescript'],
"    \   'style': ['css', 'scss', 'sass', 'less'],
"    \   'i18n': ['json', 'yaml'],
"    \   'route': 'json',
"    \},
"    \'full_syntax': ['json'],
"    \'initial_indent': ['i18n', 'i18n.json', 'yaml'],
"    \'attribute': 1,
"    \'keyword': 1,
"    \'foldexpr': 0,
"    \'debug': 0,
"    \}


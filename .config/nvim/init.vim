:set number
:set autoindent
:set tabstop=4
:set shiftwidth=4
:set smarttab
:set softtabstop=4
:set encoding=UTF-8
syntax on

call plug#begin()
Plug 'ryanoasis/vim-devicons'
Plug 'skywind3000/asyncrun.vim'
Plug 'leafOfTree/vim-vue-plugin'
Plug 'edkolev/tmuxline.vim'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'junegunn/fzf.vim'
Plug 'vim-airline/vim-airline'
Plug 'preservim/nerdtree'
Plug 'tpope/vim-surround'
Plug 'vim-syntastic/syntastic'
Plug 'mattn/emmet-vim'
Plug 'flazz/vim-colorschemes'
Plug 'sainnhe/everforest'
Plug 'ycm-core/YouCompleteMe'
call plug#end()


"alias to nerdtreetoggle"
nnoremap <c-t> :NERDTreeToggle<cr>
nnoremap <c-f> :NERDTreeFocus<cr>

colorscheme everforest 


" trigger to autocomplete "
let g:ycm_auto_trigger = 1

"transparent background"
hi Normal guibg=NONE ctermbg=NONE

let g:vim_vue_plugin_config = { 
      \'syntax': {
      \   'template': ['html'],
      \   'script': ['javascript', 'typescript'],
      \   'style': ['css', 'scss', 'sass', 'less'],
      \   'i18n': ['json', 'yaml'],
      \   'route': 'json',
      \},
      \'full_syntax': ['json'],
      \'initial_indent': ['i18n', 'i18n.json', 'yaml'],
      \'attribute': 1,
      \'keyword': 1,
      \'foldexpr': 0,
      \'debug': 0,
      \}

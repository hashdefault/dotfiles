:set number
:set autoindent
:set tabstop=4
:set shiftwidth=4
:set smarttab
:set softtabstop=4
syntax on

call plug#begin()
Plug 'https://github.com/eshion/vim-sync'
Plug 'skywind3000/asyncrun.vim'
Plug 'leafoftree/vim-vue-plugin'
Plug 'HerringtonDarkholme/yats.vim'
Plug 'maxmellon/vim-jsx-pretty'
Plug 'https://github.com/junegunn/fzf.vim'
Plug 'https://github.com/vim-airline/vim-airline'
Plug 'https://github.com/preservim/nerdtree'
Plug 'https://github.com/tpope/vim-surround'
Plug 'https://github.com/vim-syntastic/syntastic'
Plug 'https://github.com/mattn/emmet-vim'
Plug 'flazz/vim-colorschemes'
Plug 'sainnhe/everforest'
Plug 'https://github.com/arcticicestudio/nord-vim'
Plug 'https://github.com/ycm-core/YouCompleteMe'

call plug#end()


"alias to nerdtreetoggle"
nnoremap <c-t> :NERDTreeToggle<cr>

colorscheme everforest 


" trigger to autocomplete "
let g:ycm_auto_trigger = 1



" vim plug ftp alias "
nnoremap <C-U> <ESC>:call SyncUploadFile()<CR> 

nnoremap <C-D> <ESC>:call SyncDownloadFile()<CR>


g:sync_exe_filenames (default: '.sync;')

" vim vue plug config "
let g:vim_vue_plugin_config = { 
      \'syntax': {
      \   'template': ['html'],
      \   'script': ['javascript'],
      \   'style': ['css'],
      \},
      \'full_syntax': [],
      \'initial_indent': [],
      \'attribute': 0,
      \'keyword': 0,
      \'foldexpr': 0,
      \'debug': 0,
      \}

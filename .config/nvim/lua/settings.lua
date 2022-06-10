vim.opt.number = true
vim.opt.autoindent = true
vim.opt.tabstop=4
vim.opt.shiftwidth=4
vim.opt.smarttab = true
vim.opt.softtabstop=4
vim.opt.encoding='UTF-8'
vim.opt.syntax = 'enable' 
vim.opt.termguicolors = true
vim.opt.relativenumber = true
vim.wo.wrap = false

vim.api.nvim_set_keymap('n','<c-t>',':NERDTreeToggle<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n','<c-f>',':NERDTreeFocus<cr>', { noremap = true, silent = true })

vim.cmd('colorscheme onenord')
--vim.cmd('colorscheme everforest')
--vim.cmd('colorscheme nordfox')
--vim.cmd('colorscheme tender')
--vim.cmd('colorscheme nord')


--transparent background
vim.cmd('hi Normal guibg=NONE ctermbg=NONE')





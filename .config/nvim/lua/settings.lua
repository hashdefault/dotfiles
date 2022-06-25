local vim = vim
vim.opt.number=true
vim.opt.autoindent=true
vim.opt.tabstop=4
vim.opt.shiftwidth=4
vim.opt.smarttab = true
vim.opt.softtabstop=4
vim.opt.encoding='UTF-8'
vim.opt.syntax = 'enable'
vim.opt.termguicolors = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.wo.wrap = false

vim.api.nvim_set_keymap('n','<c-t>',':NvimTreeToggle<cr>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n','<c-f>',':NvimTreeFocus<cr>', { noremap = true, silent = true })

vim.cmd('colorscheme onenord')
--vim.cmd('colorscheme everforest')
--vim.cmd('colorscheme nordfox')
--vim.cmd('colorscheme tender')
--vim.cmd('colorscheme nord')


--transparent background
vim.cmd('hi Normal guibg=NONE ctermbg=NONE ')
vim.g.cursorhold_updatetime = '100'


vim.cmd('highlight DiagnosticWarn  guifg=#fcc203')
vim.cmd('highlight DiagnosticFloatingWarn guifg=#fcc203')
vim.cmd('highlight DiagnosticSignWarn  guisp=#fcc203 guifg=#fcc203')
vim.cmd('highlight DiagnosticVirtualTextWarn  guifg=#fcc203')
vim.cmd('highlight WarningMsg  guifg=#fcc203')
vim.cmd('highlight LspDiagnosticsDefaultWarning  guifg=#fcc203')
vim.cmd('highlight LspDiagnosticsUnderlineWarning  guisp=#fcc203 guifg=NONE')
vim.cmd('highlight lualine_b_diagnostics_warn_normal guifg=#fcc203 guibg=#3F4758')
vim.cmd('highlight lualine_b_diagnostics_warn_insert guifg=#fcc203 guibg=#3F4758')
vim.cmd('highlight lualine_b_diagnostics_warn_visual guifg=#fcc203 guibg=#3F4758')
vim.cmd('highlight lualine_b_diagnostics_warn_replace guifg=#fcc203 guibg=#3F4758')
vim.cmd('highlight lualine_b_diagnostics_warn_command guifg=#fcc203 guibg=#3F4758')
vim.cmd('highlight lualine_b_diagnostics_warn_terminal guifg=#fcc203 guibg=#3F4758')
vim.cmd('highlight lualine_b_diagnostics_warn_inactive guifg=#fcc203 guibg=None')

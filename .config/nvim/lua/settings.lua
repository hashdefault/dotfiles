local vim = vim
vim.opt.number = true
vim.opt.autoindent = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.smarttab = true
vim.opt.softtabstop = 4
vim.opt.encoding = "UTF-8"
vim.opt.syntax = "enable"
vim.opt.termguicolors = true
vim.opt.relativenumber = false
vim.opt.cursorline = true
vim.wo.wrap = false

-- Hold the cursor for diagnostic
vim.cmd("autocmd CursorHold * lua vim.diagnostic.open_float()")

vim.diagnostic.config({
	virtual_text = false,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = false,
	float = {
		header = " Diagnostic",
		prefix = "",
		border = "rounded",
	},
})

vim.cmd("colorscheme onenord")
--vim.cmd('colorscheme everforest')
--vim.cmd('colorscheme nordfox')
--vim.cmd('colorscheme tender')
--vim.cmd('colorscheme nord')

--transparent background
vim.cmd("hi Normal guibg=NONE ctermbg=NONE ")
vim.g.cursorhold_updatetime = "100"

vim.cmd("highlight DiagnosticWarn  guifg=#fcb103")
vim.cmd("highlight DiagnosticFloatingWarn guifg=#fcb103")
vim.cmd("highlight DiagnosticSignWarn  guisp=#fcb103 guifg=#fcc103")
vim.cmd("highlight DiagnosticVirtualTextWarn  guifg=##fcb103")
vim.cmd("highlight WarningMsg  guifg=#fcb103")
vim.cmd("highlight LspDiagnosticsDefaultWarning  guifg=#fcb103")
vim.cmd("highlight LspDiagnosticsUnderlineWarning  guisp=#fcb103 guifg=NONE")
vim.cmd("highlight lualine_b_diagnostics_warn_normal guifg=#fcb103 guibg=#3F4758")
vim.cmd("highlight lualine_b_diagnostics_warn_insert guifg=#fcb103 guibg=#3F4758")
vim.cmd("highlight lualine_b_diagnostics_warn_visual guifg=#fcb103 guibg=#3F4758")
vim.cmd("highlight lualine_b_diagnostics_warn_replace guifg=#fcb103 guibg=#3F4758")
vim.cmd("highlight lualine_b_diagnostics_warn_command guifg=#fcb103 guibg=#3F4758")
vim.cmd("highlight lualine_b_diagnostics_warn_terminal guifg=#fcb103 guibg=#3F4758")
vim.cmd("highlight lualine_b_diagnostics_warn_inactive guifg=#fcb103 guibg=None")

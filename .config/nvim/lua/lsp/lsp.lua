--LSP installer plugin
require("nvim-lsp-installer").setup({
	automatic_installation = true, -- automatically detect which servers to install (based on which servers are set up via lspconfig)
	ui = {
		icons = {
			server_installed = "✓",
			server_pending = "➜",
			server_uninstalled = "✗"
		}
	}
})
local lspconfig = require('lspconfig')

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())

--setting up all LSP needed
lspconfig.sumneko_lua.setup {capabilities = capabilities }
lspconfig.pyright.setup {capabilities = capabilities }
lspconfig.intelephense.setup {capabilities = capabilities }
lspconfig.dockerls.setup {capabilities = capabilities }
lspconfig.bashls.setup {capabilities = capabilities }
--lspconfig.eslint.setup {capabilities = capabilities }
lspconfig.tsserver.setup {capabilities = capabilities }
--lspconfig.stylelint_lsp.setup {capabilities = capabilities }
lspconfig.html.setup {capabilities = capabilities }
lspconfig.cmake.setup {capabilities = capabilities }
lspconfig.vuels.setup {capabilities = capabilities }

vim.diagnostic.config({
	source = require('lspsaga'),
	virtual_text = true,
	signs = true,
	underline = true,
	update_in_insert = false,
	severity_sort = false,
	})
--vim.diagnostic.open_float()
---- symbols to LSP dignostic
local signs = { Error = " ", Warning = " ", Hint = " ", Information = " " }
for type, icon in pairs(signs) do
	local hl = "LspDiagnosticsSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
vim.cmd('hi Warnings  guifg=#EBCB8B')
vim.cmd('hi LspDiagnosticsWarn   guifg=#EBCB8B')
vim.cmd('hi LspDiagnosticsVirtualTextWarn ctermfg=11 guifg=#EBCB8B')
vim.cmd('hi LspDiagnosticsFloatWarn   guifg=#EBCB8B')
vim.cmd('hi LspDiagnosticsSignWarn ctermfg=11 guifg=#EBCB8B')
--
--
---- LSP config to signature help (documentation of functions)
--local cfg = {
--	debug = false, -- set to true to enable debug logging
--	log_path = vim.fn.stdpath("cache") .. "/lsp_signature.log", -- log dir when debug is on
--	-- default is  ~/.cache/nvim/lsp_signature.log
--	verbose = false, -- show debug line number
--
--	bind = true, -- This is mandatory, otherwise border config won't get registered.
--	-- If you want to hook lspsaga or other signature handler, pls set to false
--	doc_lines = 10, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
--	-- set to 0 if you DO NOT want any API comments be shown
--	-- This setting only take effect in insert mode, it does not affect signature help in normal
--	-- mode, 10 by default
--
--	floating_window = true, -- show hint in a floating window, set to false for virtual text only mode
--
--	floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
--	-- will set to true when fully tested, set to false will use whichever side has more space
--	-- this setting will be helpful if you do not want the PUM and floating win overlap
--
--	floating_window_off_x = 1, -- adjust float windows x position.
--	floating_window_off_y = 1, -- adjust float windows y position.
--
--
--	fix_pos = false,  -- set to true, the floating window will not auto-close until finish all parameters
--	hint_enable = true, -- virtual hint enable
--	hint_prefix = "🤖 ",  -- robot for parameter
--	hint_scheme = "String",
--	hi_parameter = "LspSignatureActiveParameter", -- how your parameter will be highlight
--	max_height = 12, -- max height of signature floating_window, if content is more than max_height, you can scroll down
--	-- to view the hiding contents
--	max_width = 80, -- max_width of signature floating_window, line will be wrapped if exceed max_width
--	handler_opts = {
--		border = "rounded"   -- double, rounded, single, shadow, none
--	},
--
--	always_trigger = true, -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58
--
--	auto_close_after = nil, -- autoclose signature float win after x sec, disabled if nil.
--	extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
--	zindex = 200, -- by default it will be on top of all floating windows, set to <= 50 send it to bottom
--
--	padding = '', -- character to pad on left and right of signature can be ' ', or '|'  etc
--
--	transparency = nil, -- disabled by default, allow floating win transparent value 1~100
--	shadow_blend = 36, -- if you using shadow as border use this set the opacity
--	shadow_guibg = 'Black', -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
--	timer_interval = 200, -- default timer check interval set to lower value if you want to reduce latency
--	toggle_key =  nil  -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
--}
--
--require'lsp_signature'.setup(cfg) -- no need to specify bufnr if you don't use toggle_key
----require'lsp_signature'.on_attach(cfg, bufnr) -- no need to specify bufnr if you don't use toggle_key



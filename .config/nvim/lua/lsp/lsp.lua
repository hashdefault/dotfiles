--LSP installer plugin
--
--

local lsp_installer = require("nvim-lsp-installer")

lsp_installer.setup({
	automatic_installation = true, -- automatically detect which servers to install (based on which servers are set up via lspconfig)
	ui = {
		border = "rounded",
		icons = {
			server_installed = "✓",
			server_pending = "➜",
			server_uninstalled = "✗",
		},
	},
})

--some examples of symbols
--⚠
--✖
--
--ⓘ
--●
--
--
---- symbols to LSP dignostic
local lspconfig = require("lspconfig")
---- symbols to LSP dignostic
local signs = { Error = "● ", Warn = "● ", Hint = "● ", Info = "● " }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local capabilities = require("cmp_nvim_lsp").update_capabilities(vim.lsp.protocol.make_client_capabilities())

--setting up all LSP needed

lspconfig.sumneko_lua.setup({
	capabilities = capabilities,
	-- to set null-ls as default formatter
	on_attach = function(client)
		client.resolved_capabilities.document_formatting = false
	end,

	settings = {
		Lua = {
			diagnostics = {
				globals = { "vim" },
			},
		},
	},
})
lspconfig.pyright.setup({
	capabilities = capabilities,
	-- to set null-ls as default formatter
	on_attach = function(client)
		client.resolved_capabilities.document_formatting = false
	end,
})

lspconfig.intelephense.setup({
	capabilities = capabilities,

	-- to set null-ls as default formatter
	--	on_attach = function(client)
	--		client.resolved_capabilities.document_formatting = false
	--	end,
})
lspconfig.dockerls.setup({ capabilities = capabilities })
lspconfig.bashls.setup({
	capabilities = capabilities,
	-- to set null-ls as default formatter
	on_attach = function(client)
		client.resolved_capabilities.document_formatting = false
	end,
})
--lspconfig.eslint.setup {capabilities = capabilities }
lspconfig.tsserver.setup({
	capabilities = capabilities,
	-- to set null-ls as default formatter
	on_attach = function(client)
		client.resolved_capabilities.document_formatting = false
	end,
})
--lspconfig.stylelint_lsp.setup {capabilities = capabilities }
lspconfig.html.setup({
	capabilities = capabilities,
	-- to set null-ls as default formatter
	on_attach = function(client)
		client.resolved_capabilities.document_formatting = false
	end,
})
lspconfig.cmake.setup({ capabilities = capabilities })
lspconfig.vuels.setup({
	capabilities = capabilities,
	-- to set null-ls as default formatter
	on_attach = function(client)
		client.resolved_capabilities.document_formatting = false
	end,
})

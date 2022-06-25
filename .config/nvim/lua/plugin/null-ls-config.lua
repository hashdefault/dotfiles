--local null_ls_status_ok, null_ls = pcall(require,'null-ls')
--if not null_ls_status_ok then
--	return
--end
--
--
----local formatting = null_ls.builtins.formatting
----local diagnostics = null_ls.builtins.diagnostics
--
--null_ls.setup({
--	debug = true,
--})
--
--local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
--require("null-ls").setup({
--    -- you can reuse a shared lspconfig on_attach callback here
--    on_attach = function(client, bufnr)
--       if client.supports_method("textDocument/formatting") then
--    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
--            vim.api.nvim_create_autocmd("BufWritePre", {
--     group = augroup,
--                buffer = bufnr,
--         callback = function()
--           -- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
--          vim.lsp.buf.formatting_sync()
--                end,
--            })
--        end
--    end,
--})



local null_ls = require('null-ls')

local formatting = null_ls.builtins.formatting
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
null_ls.setup({
	sources = {
		formatting.prettier, formatting.black, formatting.phpcsfixer, formatting.eslint, formatting.gofmt, formatting.shfmt,
		formatting.clang_format, formatting.cmake_format, formatting.dart_format, formatting.lua_format,
		formatting.isort, formatting.codespell.with({ filetypes = { 'markdown' } })
	},
	-- you can reuse a shared lspconfig on_attach callback here
	on_attach = function(client, bufnr)
		if client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,

				callback = function()

					-- on 0.8, you should use vim.lsp.buf.format({ bufnr = bufnr }) instead
					vim.lsp.buf.formatting_seq_sync({
					})
				end,
			})
		end
	end
})



--on_attach = function(client)
--	if client.resolved_capabilities.document_formatting then
--		vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_seq_sync()")
--	end
--	vim.cmd [[
--  augroup document_highlight
--    autocmd! * <buffer>
--    autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
--    autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
--  augroup END
--]]
--end

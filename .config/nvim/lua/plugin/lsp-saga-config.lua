
local M = {}

function M.check_trigger_char(line_to_cursor, trigger_character)
	if trigger_character == nil then
		return false
	end
	for _, ch in ipairs(trigger_character) do
		local current_char = string.sub(line_to_cursor, #line_to_cursor - #ch + 1, #line_to_cursor)
		if current_char == ch then
			return true
		end
		if current_char == " " and #line_to_cursor > #ch + 1 then
			local pre_char = string.sub(line_to_cursor, #line_to_cursor - #ch, #line_to_cursor - 1)
			if pre_char == ch then
				return true
			end
		end
	end
	return false
end

function M.lspsaga_open_signature_help()
	local clients = vim.lsp.buf_get_clients(0)
	if clients == nil or clients == {} then return end

	local triggered = false
	for _, client in pairs(clients) do
		local triggers = client.server_capabilities.signatureHelpProvider.triggerCharacters

		local pos = vim.api.nvim_win_get_cursor(0)
		local line = vim.api.nvim_get_current_line()
		local line_to_cursor = line:sub(1, pos[2])

		if triggered == false then
			triggered = M.check_trigger_char(line_to_cursor, triggers)
		end
	end

	if triggered then
		require('lspsaga.signaturehelp').signature_help()
	end
end

vim.cmd "augroup Signature"
vim.cmd "autocmd! * <buffer>"
vim.cmd "autocmd InsertCharPre * lua require'plugin.lsp-saga-config'.lspsaga_open_signature_help()"
vim.cmd "augroup end"

--Hover Doc
vim.api.nvim_set_keymap('n',' K',':Lspsaga hover_doc<CR>', { noremap = true, silent = true })

--SignatureHelp
vim.api.nvim_set_keymap('n','gs',':Lspsaga signature_help<CR>', { noremap = true, silent = true })

--Rename with Preview and Select
vim.api.nvim_set_keymap('n','gr',':Lspsaga rename<CR>', { noremap = true, silent = true })

--Preview Definition
vim.api.nvim_set_keymap('n',' gd',':Lspsaga preview_definition<CR>', { noremap = true, silent = true })

--Jump Diagnostic and Show Diagnostics
vim.api.nvim_set_keymap('n',' [e',':Lspsaga diagnostic_jump_next<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n',' ]e',':Lspsaga diagnostic_jump_prev<CR>', { noremap = true, silent = true })

--code actions
vim.api.nvim_set_keymap('n','<leader>ca' ,':Lspsaga code_action<CR>', { noremap = true })

return M




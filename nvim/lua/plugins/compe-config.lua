vim.o.completeopt = 'menuone,noselect'


require'compe'.setup {
	enabled = true;
	autocomplete = true;
	debug = false;
	min_length = 1;
	preselect = 'enable';
	throttle_time = 80;
	source_timeout = 200;
	incomplete_delay = 400;
	max_abbr_width = 100;
	max_kind_width = 100;
	max_menu_width = 100;
	documentation = false;


	source = {
		path = true;
		buffer = true;
		calc = true;
		vsnip = true;
		nvim_lsp = true;
		nvim_lua = true;
		spell = true;
		tags = true;
		snippets_nvim = true;
		treesitter = true;
	};
}

local t = function(str)
	return vim.api.nvim_replace_termcodes(str, true, true, true)
end

_G.s_tab_complete = function()
	if vim.fn.pumvisible() == 1 then
		return t "<c-p>"
	elseif vim.fn.call("vsnip#jumpable", {-1}) == 1 then
		return t "<Plug>(vsnip-jump-prev)"
	else
		return t "<S-Tab>"
	end
end

vim.api.nvim_set_keymap("s","<Tab>","v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i","<S-Tab>","v:s.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s","<S-Tab>","v:s.tab_complete()", {expr = true})




---- Mappings.
---- See `:help vim.diagnostic.*` for documentation on any of the below functions
--local opts = { noremap=true, silent=true }
--vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
--vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
--vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
--vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
--
---- Use an on_attach function to only map the following keys
---- after the language server attaches to the current buffer
--local on_attach = function(client, bufnr)
--  -- Enable completion triggered by <c-x><c-o>
--  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
--
--  -- Mappings.
--  -- See `:help vim.lsp.*` for documentation on any of the below functions
--  local bufopts = { noremap=true, silent=true, buffer=bufnr }
--  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
--  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
--  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
--  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
--  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
--  vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
--  vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
--  vim.keymap.set('n', '<space>wl', function()
--    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
--  end, bufopts)
--  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
--  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
--  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
--  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
--  vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
--end
--
---- Use a loop to conveniently call 'setup' on multiple servers and
---- map buffer local keybindings when the language server attaches
--local servers = { 'pyright', 'rust_analyzer', 'tsserver' }
--for _, lsp in pairs(servers) do
--  require('lspconfig')[lsp].setup {
--    on_attach = on_attach,
--    flags = {
--      -- This will be the default in neovim 0.7+
--      debounce_text_changes = 150,
--    }
--  }
--end



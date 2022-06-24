vim.opt.completeopt = {'menu','menuone'}

--vim.cmd('set completeopt=menu,menuone,noselect')

local cmp = require'cmp'

cmp.setup({
	view = {
		entries = 'custom', --native or wildmenu
	},
	formatting = {
		format = require('lspkind').cmp_format({
			mode = "symbol_text",

	--		menu = ({
	--			buffer = "[Buffer]",
	--			nvim_lsp = "[LSP]",
	--			luasnip = "[LuaSnip]",
	--			nvim_lua = "[Lua]",
	--			latex_symbols = "[Latex]",
			--	cmp_tabnine = "[TabNine]",
			--	ultisnips = "[UltiSnips]",
	--		})
		}),
	},
	--		format = function(entry, vim_item)
	-- fancy icons and a name of kind
	--			vim_item.kind = require("lspkind").presets.default[vim_item.kind] ..
	--			" " .. vim_item.kind
	-- set a name for each source
	--vim_item.menu = ({
	--	ultisnips = "[UltiSnips]",
	--	nvim_lsp = "[LSP]",
	--	buffer = "[Buffer]",
	--	nvim_lua = "[Lua]",
	--	cmp_tabnine = "[TabNine]",
	--})[entry.source.name]
	--			return vim_item
	--		end
	--	},
	snippet = {
		-- REQUIRED - you must specify a snippet engine
		expand = function(args)
			--vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
			 require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
			-- require('snippy').expand_snippet(args.body) -- For `snippy` users.
			--vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
		end,
	},
	window = {
		--completion = cmp.config.window.bordered(),
		--documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		['<Tab>'] = function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		--{ name = 'vsnip' }, -- For vsnip users.
		{ name = 'lsp_signature' },
		{ name = 'treesitter' },
		{ name = 'luasnip' }, -- For luasnip users.
		--{ name = 'ultisnips' }, -- For ultisnips users.
		-- { name = 'snippy' }, -- For snippy users.
		}, {
			{ name = 'buffer' },
	})
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
	sources = cmp.config.sources({
		{ name = 'cmp_git' }, -- You can specify the `cmp_git` source if you were installed it.
		}, {
			{ name = 'buffer' },
	})
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer' }
	}
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
		}, {
			{ name = 'cmdline' }
	})
})


--vim.cmd('highlight! CmpItemAbbrDeprecated guibg=NONE gui=strikethrough guifg=#808080')
---- blue
--vim.cmd('highlight! CmpItemAbbrMatch guibg=NONE guifg=#569CD6')
--vim.cmd('highlight! CmpItemAbbrMatchFuzzy guibg=NONE guifg=#569CD6')
---- light blue
--vim.cmd('highlight! CmpItemKindInterface guibg=NONE guifg=#9CDCFE')
---- pink
--vim.cmd('highlight! CmpItemKindFunction guibg=NONE guifg=#C586C0')
--vim.cmd('highlight! CmpItemKindMethod guibg=NONE guifg=#C586C0')
---- front
--vim.cmd('highlight! CmpItemKindKeyword guibg=NONE guifg=#D4D4D4')
--vim.cmd('highlight! CmpItemKindProperty guibg=NONE guifg=#D4D4D4')
--vim.cmd('highlight! CmpItemKindUnit guibg=NONE guifg=#D4D4D4')
vim.cmd('highlight! CmpItemKindText guibg=NONE guifg=#569CD6')
vim.cmd('highlight! CmpItemKindVariable guibg=NONE guifg=#569CD6')
vim.cmd('highlight! CmpItemKindInterface guibg=NONE guifg=569CD6')
--vim.cmd('highlight! link CmpItemAbbr Pmenu')
vim.cmd('highlight! CmpItemKindFunction guibg=NONE guifg=#aa84aa')
vim.cmd('highlight! CmpItemKindMethod guibg=NONE guifg=#aa84aa')
vim.cmd('highlight! CmpItemKindKeyword guibg=NONE guifg=#aa84aa')
--vim.cmd('highlight! link CmpItemKind Pmenu')
--vim.cmd('highlight! link CmpItemMenu Pmenu')


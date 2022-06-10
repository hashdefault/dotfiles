
if not vim.g.airline_symbols then
	vim.cmd("let g:airline_symbols =  {}")
end
vim.g.airline_powerline_fonts = 1

-- unicode symbols
vim.cmd("let g:airline_left_sep = '»'")
vim.cmd("let g:airline_left_sep = '▶'")
vim.cmd("let g:airline_right_sep = '«'")
vim.cmd("let g:airline_right_sep = '◀'")
vim.cmd("let g:airline_symbols.colnr = ' ㏇:'")
vim.cmd("let g:airline_symbols.colnr = ' ℅:'")
vim.cmd("let g:airline_symbols.crypt = '🔒'")
vim.cmd("let g:airline_symbols.linenr = '☰'")
vim.cmd("let g:airline_symbols.linenr = ' ␊:'")
vim.cmd("let g:airline_symbols.linenr = ' ␤:'")
vim.cmd("let g:airline_symbols.linenr = '¶'")
vim.cmd("let g:airline_symbols.maxlinenr = ''")
vim.cmd("let g:airline_symbols.maxlinenr = '㏑'")
vim.cmd("let g:airline_symbols.branch = '⎇'")
vim.cmd("let g:airline_symbols.paste = 'ρ'")
vim.cmd("let g:airline_symbols.paste = 'Þ'")
vim.cmd("let g:airline_symbols.paste = '∥'")
vim.cmd("let g:airline_symbols.spell = 'Ꞩ'")
vim.cmd("let g:airline_symbols.notexists = 'Ɇ'")
vim.cmd("let g:airline_symbols.whitespace = 'Ξ'")
-- airline symbols
vim.cmd("let g:airline_left_sep = ''")
vim.cmd("let g:airline_left_alt_sep = ''")
vim.cmd("let g:airline_right_sep = ''")
vim.cmd("let g:airline_right_alt_sep = ''")
vim.cmd("let g:airline_symbols.branch = ''")
vim.cmd("let g:airline_symbols.colnr = ' :'")
vim.cmd("let g:airline_symbols.readonly = ''")
vim.cmd("let g:airline_symbols.linenr = ' :'")
vim.cmd("let g:airline_symbols.maxlinenr = '☰ '")
vim.cmd("let g:airline_symbols.dirty='⚡'")

vim.cmd('let g:airline#extensions#whitespace#enabled = 0')


vim.g.airline_theme = 'deus'




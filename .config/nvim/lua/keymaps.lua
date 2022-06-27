vim.api.nvim_set_keymap("n", "<c-t>", ":NvimTreeToggle<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<c-f>", ":NvimTreeFocus<cr>", { noremap = true, silent = true })

--Find files using Telescope command-line sugar.
vim.api.nvim_set_keymap("n", "<leader>ff", ":Telescope find_files<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>fg", ":Telescope live_grep<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>fb", ":Telescope buffers<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>fh", ":Telescope help_tags<cr>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<space>fm", ":lua vim.lsp.buf.formatting()<cr>", { noremap = true, silent = true })

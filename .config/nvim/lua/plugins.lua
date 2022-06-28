--Find files using Telescope command-line sugar.

vim.api.nvim_set_keymap("n", "<leader>ff", ":Telescope find_files<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>fg", ":Telescope live_grep<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>fb", ":Telescope buffers<cr>", { noremap = true })
vim.api.nvim_set_keymap("n", "<leader>fh", ":Telescope help_tags<cr>", { noremap = true })
--local execute = vim.api.nvim_command
--	packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
--end
vim.cmd([[packadd packer.nvim]])
return require("packer").startup(function(use)
	use({ "wbthomason/packer.nvim", opt = true })

	-- LSP
	use({ "neovim/nvim-lspconfig" })
	use({ "williamboman/nvim-lsp-installer" })
	use({ "onsails/lspkind.nvim" })
	use({ "hrsh7th/cmp-nvim-lsp" })
	use({ "hrsh7th/cmp-nvim-lsp-signature-help" })

	-- Completions, formatting and diagnostics
	use({ "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" })
	use({ "L3MON4D3/LuaSnip" })
	use({ "hrsh7th/nvim-cmp" })
	use({ "hrsh7th/cmp-buffer" })
	use({ "saadparwaiz1/cmp_luasnip" })
	use({ "hrsh7th/cmp-path" })
	use({ "hrsh7th/cmp-cmdline" })
	use({ "ray-x/cmp-treesitter" })
	use({ "hrsh7th/cmp-nvim-lua" })
	use({ "jose-elias-alvarez/null-ls.nvim", requires = { { "nvim-lua/plenary.nvim" } } })
	use({ "SirVer/ultisnips" })
	use({ "quangnguyen30192/cmp-nvim-ultisnips" })

	--Finders
	use({ "junegunn/fzf", { run = { "-> fzf#install()" } } })
	use({ "junegunn/fzf.vim" })
	use({ "nvim-telescope/telescope.nvim", requires = { { "nvim-lua/plenary.nvim" } } })

	--Helpers
	use({ "windwp/nvim-autopairs" })
	use({ "windwp/nvim-ts-autotag" })
	use({ "antoinemadec/FixCursorHold.nvim" })
	use({ "lewis6991/gitsigns.nvim" })

	--Colors
	use({ "EdenEast/nightfox.nvim" })
	use({ "rmehri01/onenord.nvim", { branch = "main" } })
	use({ "nvim-lualine/lualine.nvim" })
	use({ "kyazdani42/nvim-web-devicons" })
	use({ "kyazdani42/nvim-tree.lua" })
	use({ "flazz/vim-colorschemes" })
	use({ "sainnhe/everforest" })
	use({ "arcticicestudio/nord-vim" })
	use({ "edkolev/tmuxline.vim" })

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	--if packer_bootstrap then
	--	require('packer').sync()
	--end
	--
	--
	--call all files
	require("plugin.treesitter-config")
	require("plugin.lualine-config")
	require("plugin.telescope-config")
	require("plugin.nvimtree-config")
	require("plugin.nvimcmp-config")
	require("plugin.autopair-config")
	require("plugin.null-ls-config")
	require("plugin.gitsigns-config")
end)

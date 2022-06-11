local execute = vim.api.nvim_command
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

return require('packer').startup(function(use)
	use {'wbthomason/packer.nvim', opt = true }
	use { 'nvim-telescope/telescope.nvim', requires = { {'nvim-lua/plenary.nvim'} } }
	use {'EdenEast/nightfox.nvim' }
	use {'williamboman/nvim-lsp-installer' }
	use {'hrsh7th/nvim-compe' }
	use {'rmehri01/onenord.nvim', { branch = 'main' } }
	use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
	use {'windwp/nvim-ts-autotag' }
	use {'neovim/nvim-lspconfig' }
	use {'ray-x/lsp_signature.nvim' }
	use {'ryanoasis/vim-devicons' }
	use {'junegunn/fzf', { run = { '-> fzf#install()' } } }
	use {'junegunn/fzf.vim' }
	use {'vim-airline/vim-airline' }
	use {'vim-airline/vim-airline-themes' }
	use {'preservim/nerdtree' }
	use {'flazz/vim-colorschemes' }
	use {'sainnhe/everforest' }
	use {'arcticicestudio/nord-vim' }
	use {'jacoborus/tender.vim' }
	use {'edkolev/tmuxline.vim' }

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require('packer').sync()
	end
end)



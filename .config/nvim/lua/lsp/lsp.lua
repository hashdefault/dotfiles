
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

lspconfig.sumneko_lua.setup {}
lspconfig.pyright.setup {}
lspconfig.phpactor.setup {}
lspconfig.dockerls.setup {}
lspconfig.bashls.setup {}
lspconfig.eslint.setup {}
lspconfig.tsserver.setup {}
lspconfig.stylelint_lsp.setup {}
lspconfig.html.setup {}
lspconfig.cmake.setup {}


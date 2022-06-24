require('nvim-treesitter.configs').setup {
  ensure_installed = "all",
  autotag = { enable = true },
  highlight = { enable = true },
  indent = { enable = true }
}
require "nvim-treesitter.parsers".get_parser_configs().markdown = nil

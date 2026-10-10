-- Leader keys must be set before lazy.nvim loads plugins.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = false

require 'config.toolchain'
require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
require 'config.lazy'

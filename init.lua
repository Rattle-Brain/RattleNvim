-- ~/.config/nvim/init.lua
vim.loader.enable()        -- faster Lua module loading
vim.g.loaded_netrw = 1     -- nvim-tree replaces netrw
vim.g.loaded_netrwPlugin = 1
vim.g.mapleader = ' '      -- before anything maps with it

require('options')
require('plugins')
require('lsp')
require('completion')
require('treesitter')
require('git')
require('keymaps')

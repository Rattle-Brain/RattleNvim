-- General settings
local o = vim.o

o.mouse = 'a'
o.number = true
o.relativenumber = true
o.tabstop = 2
o.shiftwidth = 2
o.expandtab = true
o.smartindent = true
o.termguicolors = true
o.clipboard = 'unnamedplus'
o.updatetime = 250
o.timeoutlen = 500
o.cursorline = true
o.signcolumn = 'yes'
o.scrolloff = 8

o.swapfile = false
o.backup = false
o.writebackup = false
o.undofile = true
o.undodir = vim.fn.stdpath('data') .. '/undo'   -- same place as before: history kept

o.winborder = 'rounded'    -- every floating window gets a rounded border
o.pumborder = 'rounded'    -- ...and the completion menu (0.12)
o.pummaxwidth = 50         -- leave room for the docs popup next to the menu (0.12)
o.foldlevelstart = 99      -- open files unfolded (treesitter folding is on)

vim.diagnostic.config({
  virtual_text = false,     -- nothing next to the line; <leader>d shows details
  virtual_lines = false,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  jump = { float = true },  -- ]d / [d open the message in a float
  float = { source = true },
})

-- Highlight yanked text
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.hl.on_yank({ higroup = 'IncSearch', timeout = 200 }) end,
})

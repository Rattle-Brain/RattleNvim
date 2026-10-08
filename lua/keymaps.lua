local map = function(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { desc = desc }) end

-- Tabs
map('n', '<leader>tn', '<Cmd>tabnew<CR>', 'New tab')
map('n', '<leader>tc', '<Cmd>tabclose<CR>', 'Close tab')
map('n', '<leader>tl', '<Cmd>tabnext<CR>', 'Next tab')
map('n', '<leader>th', '<Cmd>tabprevious<CR>', 'Previous tab')

-- Terminal
map('n', '<leader>te', '<Cmd>term<CR>', 'Open terminal')
map('t', '<leader>tq', '<C-\\><C-n><C-w>h', 'Leave terminal')

-- Save / quit
map('n', '<leader>w', '<Cmd>wa<CR>', 'Save all')
map('n', '<leader>q', '<Cmd>q<CR>', 'Quit')
map('n', '<leader>wq', '<Cmd>wqa<CR>', 'Write and quit')
map('n', '<leader>qa', '<Cmd>qa<CR>', 'Quit all')
map('n', '<leader>qq', '<Cmd>qa!<CR>', 'Force quit')

-- Windows
map('n', '<C-h>', '<C-w>h', 'Move to left window')
map('n', '<C-j>', '<C-w>j', 'Move to bottom window')
map('n', '<C-k>', '<C-w>k', 'Move to top window')
map('n', '<C-l>', '<C-w>l', 'Move to right window')

-- File tree: nvim-tree sidebar
map('n', '<leader>n', '<Cmd>NvimTreeToggle<CR>', 'Toggle file explorer')
map('n', '<leader>n+', '<Cmd>NvimTreeResize +10<CR>', 'File explorer +10')
map('n', '<leader>n-', '<Cmd>NvimTreeResize -10<CR>', 'File explorer -10')
map('n', '<leader>e', '<Cmd>NvimTreeFindFile<CR>', 'Show current file in tree')
map('n', '<leader><CR>', '<C-]>', 'Step into')

-- Finding things: Telescope popups
map('n', '<leader>ff', '<Cmd>Telescope find_files<CR>', 'Find files')
map('n', '<leader>fg', '<Cmd>Telescope live_grep<CR>', 'Search in files')
map('n', '<leader>fd', '<Cmd>Telescope diagnostics<CR>', 'Telescope diagnostics')

-- Diagnostics
-- Toggle diagnostic virtual lines with <leader>d (line float is still on <C-w>d)
map('n', '<leader>d', function()
  local new_config = not vim.diagnostic.config().virtual_lines
  vim.diagnostic.config({ virtual_lines = new_config })
end, 'Toggle diagnostic virtual_lines')

-- Built-in goodies
map('n', '<leader>u', '<Cmd>Undotree<CR>', 'Undo tree')
map('n', '<leader>lf', function() vim.lsp.buf.format() end, 'Format buffer')

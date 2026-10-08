-- Completion without nvim-cmp
vim.o.autocomplete = true                        -- menu pops up as you type (0.12)
vim.o.complete = 'o^10,.^5,w^5,b^5'              -- LSP first, then open buffers
vim.o.completeopt = 'menuone,noselect,popup,fuzzy'
vim.o.pumheight = 12

-- No as-you-type menu inside pickers/prompts (e.g. Telescope's search box)
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'TelescopePrompt' },
  callback = function(ev) vim.bo[ev.buf].autocomplete = false end,
})

local icons = {
  Text = '', Method = '󰆧', Function = '󰊕', Constructor = '', Field = '󰇽',
  Variable = '󰂡', Class = '󰠱', Interface = '', Module = '', Property = '󰜢',
  Unit = '', Value = '󰎠', Enum = '', Keyword = '󰌋', Snippet = '',
  Color = '󰏘', File = '󰈙', Reference = '', Folder = '󰉋', EnumMember = '',
  Constant = '󰏿', Struct = '', Event = '', Operator = '󰆕', TypeParameter = '󰅲',
}

-- LSP completion: snippets, auto-imports, docs popup, kind icons
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('rs.completion', {}),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    if not client:supports_method('textDocument/completion') then return end
    vim.lsp.completion.enable(true, client.id, ev.buf, {
      autotrigger = false,   -- 'autocomplete' already opens the menu
      convert = function(item)
        local kind = vim.lsp.protocol.CompletionItemKind[item.kind] or ''
        return { kind = ((icons[kind] or '') .. ' ' .. kind), menu = '[LSP]' }
      end,
    })
  end,
})

-- <Tab>/<S-Tab>: menu navigation, or jump through snippet fields
local function tab(dir, key, fallback)
  return function()
    if vim.fn.pumvisible() == 1 then return key end
    if vim.snippet.active({ direction = dir }) then
      return ('<Cmd>lua vim.snippet.jump(%d)<CR>'):format(dir)
    end
    return fallback
  end
end
vim.keymap.set({ 'i', 's' }, '<Tab>', tab(1, '<C-n>', '<Tab>'), { expr = true })
vim.keymap.set({ 'i', 's' }, '<S-Tab>', tab(-1, '<C-p>', '<S-Tab>'), { expr = true })

-- <CR> accepts only an item you picked with <Tab>; otherwise it's a normal Enter
vim.keymap.set('i', '<CR>', function()
  if vim.fn.pumvisible() == 1 and vim.fn.complete_info({ 'selected' }).selected ~= -1 then
    return '<C-y>'
  end
  return vim.fn.pumvisible() == 1 and '<C-e><CR>' or '<CR>'
end, { expr = true })

-- <C-Space>: open the menu on demand (LSP if attached, otherwise buffer words)
vim.keymap.set('i', '<C-Space>', function()
  return vim.bo.omnifunc ~= '' and '<C-x><C-o>' or '<C-n>'
end, { expr = true })

-- Command-line autocompletion for :, / and ?
vim.o.wildmode = 'noselect:lastused,full'
vim.o.wildoptions = 'pum'
vim.api.nvim_create_autocmd('CmdlineChanged', {
  pattern = { ':', '/', '?' },
  callback = function() vim.fn.wildtrigger() end,
})
-- <C-j>/<C-k> move through command-line suggestions (like in Telescope)
vim.keymap.set('c', '<C-j>', function() return vim.fn.wildmenumode() == 1 and '<C-n>' or '<C-j>' end, { expr = true })
vim.keymap.set('c', '<C-k>', function() return vim.fn.wildmenumode() == 1 and '<C-p>' or '<C-k>' end, { expr = true })

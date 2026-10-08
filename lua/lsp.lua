-- Language servers installed with Mason live here; no Mason plugin needed to use them
local mason_bin = vim.fn.stdpath('data') .. '/mason/bin'
if vim.uv.fs_stat(mason_bin) then
  vim.env.PATH = mason_bin .. ':' .. vim.env.PATH
end

-- Config name -> executable. Only installed servers get enabled.
local servers = {
  jdtls         = 'jdtls',
  pyright       = 'pyright-langserver',
  clangd        = 'clangd',
  gopls         = 'gopls',
  zls           = 'zls',
  asm_lsp       = 'asm-lsp',
  rust_analyzer = 'rust-analyzer',
  terraformls   = 'terraform-ls',
  helm_ls       = 'helm_ls',
  yamlls        = 'yaml-language-server',
}
for name, bin in pairs(servers) do
  if vim.fn.executable(bin) == 1 then vim.lsp.enable(name) end
end

-- Helm templates (no vim-helm needed)
local function in_chart(path) return vim.fs.root(path, 'Chart.yaml') ~= nil end
vim.filetype.add({
  pattern = {
    ['.*/templates/.*%.ya?ml'] = function(path) if in_chart(path) then return 'helm' end end,
    ['.*/templates/.*%.tpl'] = 'helm',
    ['.*/values.*%.ya?ml'] = function(path) if in_chart(path) then return 'yaml.helm-values' end end,
  },
})

-- Peek a definition in a floating window without leaving the file
local function peek_definition()
  local client = vim.lsp.get_clients({ bufnr = 0, method = 'textDocument/definition' })[1]
  if not client then return vim.notify('No LSP definition provider', vim.log.levels.WARN) end
  local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
  client:request('textDocument/definition', params, function(_, result)
    if result and not vim.tbl_isempty(result) then
      vim.lsp.util.preview_location(vim.islist(result) and result[1] or result, { border = 'rounded' })
    end
  end, 0)
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('rs.lsp', {}),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, silent = true, desc = desc })
    end

    -- Navigation (multiple results go to the quickfix list; Ctrl-o jumps back)
    map('n', 'gd', function() vim.lsp.buf.definition({ reuse_win = true }) end, 'Go to definition')
    map('n', 'gD', vim.lsp.buf.declaration, 'Go to declaration')
    map('n', 'gi', vim.lsp.buf.implementation, 'Go to implementation')
    map('n', 'gt', vim.lsp.buf.type_definition, 'Go to type definition')
    map('n', 'gr', vim.lsp.buf.references, 'References')
    map('n', 'gp', peek_definition, 'Peek definition')
    map('n', '<leader>fr', vim.lsp.buf.references, 'Find references')

    -- Docs (K is mapped by default)
    map({ 'n', 'i' }, '<C-s>', vim.lsp.buf.signature_help, 'Signature help')

    -- Code actions and refactoring
    map({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, 'Code action')
    map('n', '<leader>rn', vim.lsp.buf.rename, 'Rename symbol')

    -- Symbols
    map('n', '<leader>ds', vim.lsp.buf.document_symbol, 'Document symbols')
    map('n', '<leader>ws', function() vim.lsp.buf.workspace_symbol() end, 'Workspace symbols')

    -- Inlay hints toggle
    if client:supports_method('textDocument/inlayHint') then
      map('n', '<leader>ih', function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
      end, 'Toggle inlay hints')
    end

    -- Highlight other occurrences of the symbol under the cursor
    if client:supports_method('textDocument/documentHighlight') then
      local g = vim.api.nvim_create_augroup('rs.lsp.highlight.' .. ev.buf, { clear = true })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        group = g, buffer = ev.buf, callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI', 'BufLeave' }, {
        group = g, buffer = ev.buf, callback = vim.lsp.buf.clear_references,
      })
    end
  end,
})

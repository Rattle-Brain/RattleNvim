-- Treesitter: parsers from nvim-treesitter, highlighting from Neovim
local ts = require('nvim-treesitter')
local has_cli = vim.fn.executable('tree-sitter') == 1

if has_cli then
  ts.install({
    'java', 'python', 'c', 'cpp', 'go', 'gomod', 'lua', 'vim', 'vimdoc', 'zig',
    'bash', 'json', 'yaml', 'toml', 'markdown', 'markdown_inline', 'query', 'comment',
    'hcl', 'terraform', 'helm', 'nasm',
  })
else
  vim.schedule(function()
    vim.notify('tree-sitter CLI not found: run `sudo pacman -S tree-sitter-cli` to get parsers', vim.log.levels.WARN)
  end)
end

local available = {}
for _, lang in ipairs(has_cli and ts.get_available() or {}) do available[lang] = true end
local installing = {}

local function enable(buf, lang)
  if not pcall(vim.treesitter.start, buf, lang) then return false end
  vim.wo[0][0].foldmethod = 'expr'
  vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
  vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  return true
end

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('rs.treesitter', {}),
  callback = function(ev)
    local lang = vim.treesitter.language.get_lang(ev.match) or ev.match
    if enable(ev.buf, lang) or not available[lang] or installing[lang] then return end
    -- auto_install: fetch the missing parser, then turn highlighting on
    installing[lang] = true
    ts.install(lang):await(vim.schedule_wrap(function()
      installing[lang] = nil
      if vim.api.nvim_buf_is_valid(ev.buf) then
        vim.api.nvim_buf_call(ev.buf, function() enable(ev.buf, lang) end)
      end
    end))
  end,
})

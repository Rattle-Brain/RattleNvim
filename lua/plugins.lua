-- Plugins, managed by the built-in vim.pack
local gh = function(repo) return 'https://github.com/' .. repo end

-- Rebuild treesitter parsers when the plugin is installed/updated
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'nvim-treesitter' and (kind == 'install' or kind == 'update') then
      if not ev.data.active then vim.cmd.packadd('nvim-treesitter') end
      if vim.fn.executable('tree-sitter') == 1 then vim.cmd('TSUpdate') end
    end
  end,
})

vim.pack.add({
  gh('webhooked/kanso.nvim'),
  gh('nvim-tree/nvim-web-devicons'),    -- file icons (needs a Nerd Font)
  gh('nvim-tree/nvim-tree.lua'),        -- file tree sidebar
  gh('neovim/nvim-lspconfig'),
  { src = gh('nvim-treesitter/nvim-treesitter'), version = 'main' },
  gh('windwp/nvim-autopairs'),
  gh('nvim-lua/plenary.nvim'),          -- telescope dependency
  gh('nvim-telescope/telescope.nvim'),  -- fuzzy finder popup
})

-- Opt-in plugins that ship with Neovim
vim.cmd.packadd('nvim.undotree')   -- :Undotree
vim.cmd.packadd('nvim.difftool')   -- :DiffTool

require('nvim-autopairs').setup()

require('telescope').setup({
  defaults = {
    mappings = {
      i = {
        ['<C-j>'] = 'move_selection_next',
        ['<C-k>'] = 'move_selection_previous',
      },
    },
  },
})

require('nvim-tree').setup({
  view = { width = 40, side = 'left' },
  filters = { dotfiles = false },
})

require('kanso').setup({
        transparent = true,
        terminalColors = true,
        foreground = 'saturated', -- a bit more contrast between token kinds
        keywordStyle = { italic = true, bold = true },
        -- Kanso leaves most identifiers in plain fg; give the common ones their own colors
        overrides = function(colors)
          local p = colors.palette
          return {
            -- Fields / properties (obj.field, struct members, dict keys)
            ['@variable.member'] = { fg = p.yellow3Saturated },
            ['@property'] = { fg = p.yellow3Saturated },
            ['@lsp.type.property'] = { fg = p.yellow3Saturated },
            ['@lsp.type.field'] = { fg = p.yellow3Saturated },
            -- Parameters are gray by default, which reads as "disabled"
            ['@variable.parameter'] = { fg = p.orange2Saturated },
            ['@lsp.type.parameter'] = { fg = p.orange2Saturated },
            -- Theme sets this to "none", which wipes treesitter colors under LSP semantic tokens
            ['@lsp.type.variable'] = {},
            -- Modules / packages / namespaces (fmt, java.util, std)
            ['@module'] = { fg = p.aquaSaturated, italic = true },
            ['@lsp.type.namespace'] = { fg = p.aquaSaturated, italic = true },
            -- Types, constructors and builtins
            ['@constructor'] = { fg = p.aquaSaturated },
            ['@type.builtin'] = { fg = p.aquaSaturated, italic = true },
            ['@lsp.type.class'] = { fg = p.aquaSaturated },
            ['@lsp.type.interface'] = { fg = p.aquaSaturated, italic = true },
            ['@lsp.type.enumMember'] = { fg = p.orangeSaturated },
            ['@lsp.mod.readonly'] = { fg = p.orangeSaturated },
            ['@lsp.typemod.variable.readonly'] = { fg = p.orangeSaturated },
            -- Function calls vs definitions
            ['@function.call'] = { fg = p.blue3Saturated },
            ['@function.method.call'] = { fg = p.blue3Saturated },
            ['@function.builtin'] = { fg = p.blueSaturated, italic = true },
            -- LSP reference highlighting (used by document_highlight below)
            LspReferenceText = { bg = p.inkBg3 },
            LspReferenceRead = { bg = p.inkBg3 },
            LspReferenceWrite = { bg = p.inkBg3, underline = true },
          }
        end,
      })
      vim.cmd('colorscheme kanso')

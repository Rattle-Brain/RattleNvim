-- ~/.config/nvim/after/lsp/gopls.lua
return {
  settings = {
    gopls = {
      analyses = { unusedparams = true },
      staticcheck = true,
      gofumpt = true,
    },
  },
}

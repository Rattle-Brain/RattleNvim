-- ~/.config/nvim/after/lsp/yamlls.lua
return {
  settings = {
    yaml = {
      validate = true,
      completion = true,
      -- Auto-detects schemas for GitHub Actions, docker-compose, etc.
      schemaStore = { enable = true, url = 'https://www.schemastore.org/api/json/catalog.json' },
      -- Kubernetes manifests, matched by file name
      schemas = {
        kubernetes = {
          '*deployment*.{yml,yaml}', '*service*.{yml,yaml}', '*ingress*.{yml,yaml}',
          '*configmap*.{yml,yaml}', '*secret*.{yml,yaml}', '*statefulset*.{yml,yaml}',
          '*pod*.{yml,yaml}', 'k8s/**/*.{yml,yaml}',
        },
      },
    },
  },
}

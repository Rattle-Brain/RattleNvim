-- ~/.config/nvim/after/lsp/jdtls.lua
local style = vim.fn.stdpath('config') .. '/lang-servers/intellij-java-google-style.xml'

return {
  settings = {
    java = {
      codeGeneration = {
        toString = { template = '${object.className}{${member.name()}=${member.value}, ${otherMembers}}' },
        useBlocks = true,
      },
      completion = {
        favoriteStaticMembers = {
          'org.junit.Assert.*', 'org.junit.Assume.*',
          'org.junit.jupiter.api.Assertions.*', 'org.junit.jupiter.api.Assumptions.*',
          'org.junit.jupiter.api.DynamicContainer.*', 'org.junit.jupiter.api.DynamicTest.*',
          'org.mockito.Mockito.*', 'org.mockito.ArgumentMatchers.*', 'org.mockito.Answers.*',
        },
        filteredTypes = { 'com.sun.*', 'io.micrometer.shaded.*', 'java.awt.*', 'jdk.*', 'sun.*' },
        importOrder = { 'java', 'javax', 'org', 'com' },
      },
      sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
      format = {
        enabled = true,
        -- Google style only if the XML actually exists
        settings = vim.uv.fs_stat(style) and { url = style, profile = 'GoogleStyle' } or nil,
      },
      configuration = {
        runtimes = {
          { name = 'JavaSE-11', path = '/usr/lib/jvm/java-11-openjdk/' },
          { name = 'JavaSE-17', path = '/usr/lib/jvm/java-17-openjdk/' },
          { name = 'JavaSE-21', path = '/usr/lib/jvm/java-21-openjdk/' },
        },
      },
      maven = { downloadSources = true },
      eclipse = { downloadSources = true },
      referencesCodeLens = { enabled = true },
      inlayHints = { parameterNames = { enabled = 'all' } },
      signatureHelp = { enabled = true },
    },
  },
}

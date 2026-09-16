return {
  -- Mason: install cucumber LSP
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "cucumber-language-server" },
    },
  },

  -- LSP: configure cucumber language server
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        cucumber_language_server = {
          filetypes = { "cucumber" },
        },
      },
    },
  },
}

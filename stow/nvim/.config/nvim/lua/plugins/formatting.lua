return {
  -- Auto-format on save with conform.nvim (LazyVim default)
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      opts.formatters_by_ft.python = { "ruff_format", "ruff_organize_imports" }
      opts.formatters_by_ft.markdown = { "prettierd", "prettier", stop_after_first = true }
      opts.formatters_by_ft.go = { "gofumpt", "goimports" }
      opts.format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
      }
      return opts
    end,
  },

  -- Ensure formatters are installed
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "prettierd",
      },
    },
  },
}

return {
  -- Auto-format on save with conform.nvim (LazyVim default)
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        python = { "ruff_format", "ruff_organize_imports" },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        go = { "gofumpt", "goimports" },
        fish = {}, -- disable fish (not used)
      },
    },
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

  -- Disable latex in render-markdown (no latex tools installed)
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      latex = { enabled = false },
    },
  },
}

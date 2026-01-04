return {
  -- Dracula theme
  { "Mofiqul/dracula.nvim", 
    priority = 1000, 
    config = function()
      require("lazy.core.loader").disable_rtp_plugin("tokyonight.nvim")
      vim.cmd([[colorscheme dracula]])
    end 
  },

  -- FZF integration
  { 
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>f", "<cmd>FzfLua files<cr>", desc = "Find Files" },
      { "<leader>g", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
    },
    config = function()
      require("fzf-lua").setup({
        winopts = {
          height = 0.4,
          width = 0.8,
          preview = { hidden = "hidden" }
        }
      })
    end
  },

  -- Clipboard support
  { 
    "gbprod/yanky.nvim",
    dependencies = { "kkharji/sqlite.lua" },
    opts = {
      highlight = { timer = 250 },
      ring = { storage = "sqlite" }
    },
    keys = {
      { "p", "<Plug>(yanky-p)", mode = { "n", "x" } },
      { "P", "<Plug>(yanky-P)", mode = { "n", "x" } },
      { "<c-n>", "<Plug>(yanky-cycle-forward)" },
      { "<c-p>", "<Plug>(yanky-cycle-backward)" },
    }
  }
}
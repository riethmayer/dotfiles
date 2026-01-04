return {
  -- Dracula theme (override LazyVim default tokyonight)
  {
    "Mofiqul/dracula.nvim",
    priority = 1000,
    config = function()
      require("lazy.core.loader").disable_rtp_plugin("tokyonight.nvim")
      vim.cmd([[colorscheme dracula]])
    end,
  },
}
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
  -- Show hidden/ignored files in explorer by default
  {
    "folke/snacks.nvim",
    opts = {
      explorer = {
        replace_netrw = true,
      },
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
          },
        },
      },
    },
  },
}
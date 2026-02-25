return {
  -- Dracula theme (override LazyVim default tokyonight)
  {
    "Mofiqul/dracula.nvim",
    priority = 1000,
    config = function()
      require("dracula").setup({
        overrides = function(colors)
          return {
            -- Fix dark-on-dark gitignored files in snacks explorer
            SnacksPickerPathIgnored = { fg = colors.bright_blue },
            SnacksPickerGitStatusIgnored = { fg = colors.bright_blue },
          }
        end,
      })
      require("lazy.core.loader").disable_rtp_plugin("tokyonight.nvim")
      vim.cmd([[colorscheme dracula]])
    end,
  },
  -- Disable neo-tree (using snacks.explorer instead)
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  -- Show hidden/ignored files in explorer by default
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>e", function() Snacks.explorer() end, desc = "Explorer" },
    },
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
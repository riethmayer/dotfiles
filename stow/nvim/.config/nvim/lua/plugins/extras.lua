return {
  -- Dracula (dark) + catppuccin-latte (light), swapped by auto-dark-mode
  -- in lockstep with macOS appearance / toggle-mode / Ghostty. Catppuccin
  -- chosen over tokyonight-day for stronger snacks.explorer + devicon
  -- contrast on light bg.
  {
    "Mofiqul/dracula.nvim",
    lazy = false,
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
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = { flavour = "latte" },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "dracula" } },
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    priority = 1001,
    opts = {
      update_interval = 3000,
      set_dark_mode = function()
        vim.opt.background = "dark"
        vim.cmd.colorscheme("dracula")
      end,
      set_light_mode = function()
        vim.opt.background = "light"
        vim.cmd.colorscheme("catppuccin-latte")
      end,
    },
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
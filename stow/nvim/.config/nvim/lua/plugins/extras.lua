return {
  -- oxocarbon (IBM Carbon-inspired) handles both dark and light via
  -- vim.opt.background. auto-dark-mode flips it in lockstep with macOS
  -- appearance / toggle-mode / Ghostty.
  {
    "nyoom-engineering/oxocarbon.nvim",
    lazy = false,
    priority = 1000,
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "oxocarbon" } },
  {
    "f-person/auto-dark-mode.nvim",
    lazy = false,
    priority = 1001,
    opts = {
      update_interval = 3000,
      set_dark_mode = function()
        vim.opt.background = "dark"
        vim.cmd.colorscheme("oxocarbon")
      end,
      set_light_mode = function()
        vim.opt.background = "light"
        vim.cmd.colorscheme("oxocarbon")
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

return {
  "hat0uma/csvview.nvim",
  ft = { "csv", "tsv" },
  cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
  keys = {
    { "<leader>uv", "<cmd>CsvViewToggle<cr>", desc = "Toggle CSV View", ft = { "csv", "tsv" } },
  },
  opts = {
    view = { display_mode = "border" },
    parser = { comments = { "#", "//" } },
    keymaps = {
      textobject_field_inner = { "if", mode = { "o", "x" } },
      textobject_field_outer = { "af", mode = { "o", "x" } },
      jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
      jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
      jump_next_row = { "<Enter>", mode = { "n", "v" } },
      jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
    },
  },
  config = function(_, opts)
    require("csvview").setup(opts)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "csv", "tsv" },
      callback = function(ev)
        require("csvview").enable(ev.buf)
      end,
    })
  end,
}

-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

-- F5: find files, F6: grep
map("n", "<F5>", "<cmd>FzfLua files<cr>", { desc = "Find Files" })
map("n", "<F6>", "<cmd>FzfLua live_grep<cr>", { desc = "Grep" })

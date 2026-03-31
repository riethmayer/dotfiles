if not vim.g.neovide then
  return {}
end

-- Neovide GUI settings
vim.o.guifont = "GeistMono Nerd Font Mono:h16"
vim.g.neovide_padding_top = 4
vim.g.neovide_padding_bottom = 4
vim.g.neovide_padding_left = 8
vim.g.neovide_padding_right = 8

-- Cursor animations
vim.g.neovide_cursor_animation_length = 0.08
vim.g.neovide_cursor_trail_size = 0.4
vim.g.neovide_cursor_vfx_mode = "railgun"

-- Smooth scroll
vim.g.neovide_scroll_animation_length = 0.2
vim.g.neovide_scroll_animation_far_lines = 1

-- Window
vim.g.neovide_remember_window_size = true
vim.g.neovide_hide_mouse_when_typing = true

-- macOS specific
vim.g.neovide_input_macos_option_key_is_meta = "only_left"

-- Clipboard keymaps (Cmd+C/V in GUI)
vim.keymap.set("v", "<D-c>", '"+y', { desc = "Copy (GUI)" })
vim.keymap.set({ "n", "v" }, "<D-v>", '"+P', { desc = "Paste (GUI)" })
vim.keymap.set({ "i", "c" }, "<D-v>", "<C-r>+", { desc = "Paste (GUI)" })
vim.keymap.set("t", "<D-v>", '<C-\\><C-n>"+Pi', { desc = "Paste in terminal (GUI)" })

return {}

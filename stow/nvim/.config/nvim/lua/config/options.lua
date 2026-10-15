-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- TypeScript 7 ships a native LSP. Effect projects patch their workspace
-- compiler with @effect/tsgo, so this selects it without running vtsls beside it.
vim.g.lazyvim_ts_lsp = "tsc"

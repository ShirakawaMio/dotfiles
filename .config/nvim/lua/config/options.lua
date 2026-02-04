-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    code = {
      enabled = true,
      language = true,
      style = "full",
    },
    checkbox = {
      enabled = true,
    },
  },
}

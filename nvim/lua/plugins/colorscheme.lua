return {
  {
    "version14/nvim-theme",
    name = "version14",
    -- pinned to dark explicitly, rather than relying on the plugin's default
    init = function()
      vim.g.version14_style = "dark"
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "version14",
    },
  },
}

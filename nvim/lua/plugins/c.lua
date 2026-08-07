return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      if not opts.servers then
        opts.servers = {}
      end
      opts.servers.clangd = {
        mason = false,
      }
      return opts
    end,
  },
}

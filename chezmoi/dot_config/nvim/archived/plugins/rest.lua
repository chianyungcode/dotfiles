-- A very fast, powerful, extensible and asynchronous Neovim HTTP client written in Lua. Postman like in Neovim
return {
  "rest-nvim/rest.nvim",
  enabled = false,
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      table.insert(opts.ensure_installed, "http")
    end,
  },
}

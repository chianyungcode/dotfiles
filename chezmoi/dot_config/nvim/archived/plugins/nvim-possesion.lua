if true then
  return {}
end

return {
  "gennaro-tedesco/nvim-possession",
  lazy = false,
  dependencies = {
    {
      "tiagovla/scope.nvim",
      lazy = false,
      config = true,
    },
  },
  config = function()
    require("nvim-possession").setup({
      autoload = true,
      autoswitch = {
        enable = true,
      },
      save_hook = function()
        vim.cmd([[ScopeSaveState]]) -- Scope.nvim saving
      end,
      post_hook = function()
        vim.cmd([[ScopeLoadState]]) -- Scope.nvim loading
      end,
    })
  end,
}

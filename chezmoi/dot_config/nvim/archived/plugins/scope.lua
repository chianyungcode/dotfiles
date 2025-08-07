if true then
  return {}
end

return {
  { "tiagovla/scope.nvim", config = true },
  config = function()
    require("scope").setup({})
  end,
}

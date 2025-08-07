if true then
  return {}
end

-- plugin that showing indent line, whitespace etc.
-- https://github.com/shellRaining/hlchunk.nvim

return {
  "shellRaining/hlchunk.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("hlchunk").setup({
      chunk = {
        enable = true,
      },
    })
  end,
}

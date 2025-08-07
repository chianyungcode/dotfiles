-- if true then
-- 	return {}
-- end

-- Belum stable

return {
  -- Lazy.nvim
  {
    "you-n-g/navigate-note.nvim",
    enabled = false,
    config = true,
    opts = {
      link_surround = {
        left = "{{",
        right = "}}",
      },
    },
  },
}

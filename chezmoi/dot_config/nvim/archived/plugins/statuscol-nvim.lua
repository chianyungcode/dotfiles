return {
  {
    "luukvbaal/statuscol.nvim",
    enabled = false,
    config = function()
      local builtin = require("statuscol.builtin")
      local utils = require("utils.status-column-util")

      require("statuscol").setup({
        -- configuration goes here, for example:
        relculright = true,
        segments = {
          { text = { builtin.foldfunc }, click = "v:lua.ScFa" },
          {
            sign = { namespace = { "diagnostic/signs" }, maxwidth = 2, auto = true },
            click = "v:lua.ScSa",
          },
          { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
          {
            sign = { name = { ".*" }, maxwidth = 2, colwidth = 1, auto = true, wrap = true },
            click = "v:lua.ScSa",
          },
        },
      })
    end,
  },
}

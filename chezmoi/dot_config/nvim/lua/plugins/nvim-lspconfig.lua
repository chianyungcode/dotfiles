return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    local keys = require("lazyvim.plugins.lsp.keymaps").get()
    -- disable a keymap
    -- Ini adalah default untuk hover kode, keymap ini saya disable karena berbenturan dengan plugin hover.lua . Sebenarnya sama saja fungsinya sama-sama untuk menghover suatu kode, tetapi dengan plugin bisa di customize lebih lagi.
    keys[#keys + 1] = { "K", false }
  end,
}

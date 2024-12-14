return {
  "smjonas/inc-rename.nvim",

  dependencies = {
    {
      -- for the better input component
      "folke/noice.nvim",
      optional = true,
      opts = {
        presets = { inc_rename = true },
      },
    },
  },

  keys = {
    {
      "<leader>cr",
      function()
        local inc_rename = require("inc_rename")
        return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
      end,
      expr = true,
      desc = "Rename (inc-rename.nvim)",
    }
  },
  config = function()
    require("inc_rename").setup({})
  end,
}

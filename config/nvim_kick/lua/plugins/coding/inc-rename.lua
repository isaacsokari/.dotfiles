return { {
  "smjonas/inc-rename.nvim",
  keys = {
    { 
      "<leader>cr",
      function()
        local inc_rename = require("inc_rename")
        return ":" .. inc_rename.config.cmd_name .. " " .. vim.fn.expand("<cword>")
      end,
      expr = true,
      desc = "Rename (inc-rename.nvim)",
      has = "rename",
    }
  },
  config = function()
    require("inc_rename").setup()
  end,
} }

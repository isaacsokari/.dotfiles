-- Terminal Mappings
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

return {
  "folke/snacks.nvim",

  opts = function()
    ---@type snacks.Config
    return {
      bigfile = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = false }, -- we set this in options.lua
      terminal = {
        win = {
          keys = {
            nav_h = { "<C-h>", term_nav("h"), desc = "Go to Left Window", expr = true, mode = "t" },
            nav_j = { "<C-j>", term_nav("j"), desc = "Go to Lower Window", expr = true, mode = "t" },
            nav_k = { "<C-k>", term_nav("k"), desc = "Go to Upper Window", expr = true, mode = "t" },
            nav_l = { "<C-l>", term_nav("l"), desc = "Go to Right Window", expr = true, mode = "t" },
          },
        },
      },
      toggle = { map = LazyVim.safe_keymap_set },
      words = { enabled = true },
    }
  end,

  keys = {
    {
      "<leader>.",
      function()
        Snacks.scratch()
      end,
      desc = "Toggle Scratch Buffer",
    },
    {
      "<leader>S",
      function()
        Snacks.scratch.select()
      end,
      desc = "Select Scratch Buffer",
    },
    {
      "<leader>n",
      function()
        Snacks.notifier.show_history()
      end,
      desc = "Notification History",
    },
    {
      "<leader>un",
      function()
        Snacks.notifier.hide()
      end,
      desc = "Dismiss All Notifications",
    },
  },

  config = function(_, opts)
    local snacks = require("snacks")
    local keymap = vim.keymap

    -- floating terminal
    keymap.set("n", "<leader>fT", function()
      snacks.terminal()
    end, { desc = "Terminal (cwd)" })

    keymap.set("n", "<leader>ft", function()
      snacks.terminal(nil, { cwd = snacks.git.get_root() })
    end, { desc = "Terminal (Root Dir)" })

    keymap.set("n", "<c-/>", function()
      snacks.terminal(nil, { cwd = snacks.git.get_root() })
    end, { desc = "Terminal (Root Dir)" })

    keymap.set("n", "<c-_>", function()
      snacks.terminal(nil, { cwd = snacks.git.get_root() })
    end, { desc = "which_key_ignore" })

    -- lazygit
    keymap.set("n", "<leader>gG", function()
      snacks.lazygit({ cwd = snacks.git.get_root() })
    end, { desc = "Lazygit (Root Dir)" })

    keymap.set("n", "<leader>gg", function()
      snacks.lazygit()
    end, { desc = "Lazygit (cwd)" })

    keymap.set("n", "<leader>gb", function()
      snacks.git.blame_line()
    end, { desc = "Git Blame Line" })

    keymap.set("n", "<leader>gf", function()
      local git_path = vim.api.nvim_buf_get_name(0)
      snacks.lazygit({ args = { "-f", vim.trim(git_path) } })
    end, { desc = "Lazygit Current File History" })

    snacks.setup(opts)
  end,
}

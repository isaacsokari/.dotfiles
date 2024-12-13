return {
  "folke/snacks.nvim",
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

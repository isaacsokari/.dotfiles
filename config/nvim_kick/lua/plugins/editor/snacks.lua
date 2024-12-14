-- local common_utils = require('ts.utils.common')

-- Terminal Mappings
local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and "<c-" .. dir .. ">" or vim.schedule(function()
      vim.cmd.wincmd(dir)
    end)
  end
end

-- Wrapper around vim.keymap.set that will
-- not create a keymap if a lazy key handler exists.
-- It will also set `silent` to true by default.
local function safe_keymap_set(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  local modes = type(mode) == "string" and { mode } or mode

  ---@param m string
  modes = vim.tbl_filter(function(m)
    return not (keys.have and keys:have(lhs, m))
  end, modes)

  -- do not create the keymap if a lazy keys handler exists
  if #modes > 0 then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      ---@diagnostic disable-next-line: no-unknown
      opts.remap = nil
    end
    vim.keymap.set(modes, lhs, rhs, opts)
  end
end

return {
  "folke/snacks.nvim",

  opts = {
    bigfile = { enabled = true },

    -- dashboard = { enabled = true },

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

    toggle = { map = safe_keymap_set },
    words = { enabled = true },
  },


  keys = {
    { "<leader>.",  function() Snacks.scratch() end,               desc = "Toggle Scratch Buffer", },
    { "<leader>S",  function() Snacks.scratch.select() end,        desc = "Select Scratch Buffer", },
    { "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Notification History", },
    { "<leader>un", function() Snacks.notifier.hide() end,         desc = "Dismiss All Notifications", },
  },

  config = function(_, opts)
    local snacks = require("snacks")
    local keymap = vim.keymap

    -- buffer
    keymap.set("n", "<leader>bd", function()
      Snacks.bufdelete()
    end, { desc = "Delete Buffer" })

    keymap.set("n", "<leader>bo", function()
      Snacks.bufdelete.other()
    end, { desc = "Delete Other Buffers" })

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
    if vim.fn.executable("lazygit") == 1 then
      keymap.set("n", "<leader>gG", function()
        snacks.lazygit({ cwd = snacks.git.get_root() })
      end, { desc = "Lazygit (Root Dir)" })

      keymap.set("n", "<leader>gg", function()
        snacks.lazygit()
      end, { desc = "Lazygit (cwd)" })

      keymap.set("n", "<leader>gb", function()
        snacks.git.blame_line()
      end, { desc = "Git Blame Line" })

      keymap.set({ "n", "x" }, "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse (open)" })
      keymap.set({ "n", "x" }, "<leader>gY", function()
        Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false })
      end, { desc = "Git Browse (copy)" })

      keymap.set("n", "<leader>gf", function()
        local git_path = vim.api.nvim_buf_get_name(0)
        snacks.lazygit({ args = { "-f", vim.trim(git_path) } })
      end, { desc = "Lazygit Current File History" })
    end


    -- toggle options
    Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
    Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
    Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
    Snacks.toggle.diagnostics():map("<leader>ud")
    Snacks.toggle.line_number():map("<leader>ul")
    Snacks.toggle.option("conceallevel",
      { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }):map("<leader>uc")
    Snacks.toggle.option("showtabline",
      { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" }):map("<leader>uA")
    Snacks.toggle.treesitter():map("<leader>uT")
    Snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
    if vim.lsp.inlay_hint then
      Snacks.toggle.inlay_hints():map("<leader>uh")
    end


    snacks.setup(opts)
  end
}

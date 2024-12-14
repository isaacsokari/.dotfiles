local common_utils = require("ts.utils.common")

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "diff",
        "html",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "printf",
        "python",
        "query",
        "regex",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
      highlight = {
        enable = true,
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_decremental = "<bs>",
          node_incremental = "<C-space>",
          scope_incremental = false,
        },
      },
      indent = {
        enable = true,
      },
      textobjects = {
        move = {
          enable = true,
          goto_next_end = {
            ["]A"] = "@parameter.inner",
            ["]C"] = "@class.outer",
            ["]F"] = "@function.outer",
          },
          goto_next_start = {
            ["]a"] = "@parameter.inner",
            ["]c"] = "@class.outer",
            ["]f"] = "@function.outer",
          },
          goto_previous_end = {
            ["[A"] = "@parameter.inner",
            ["[C"] = "@class.outer",
            ["[F"] = "@function.outer",
          },
          goto_previous_start = {
            ["[a"] = "@parameter.inner",
            ["[c"] = "@class.outer",
            ["[f"] = "@function.outer",
          },
        },
      },
    },

    -- _opts = {
    --   ensure_installed = {
    --     "bash",
    --     "html",
    --     "javascript",
    --     "json",
    --     "lua",
    --     "markdown",
    --     "markdown_inline",
    --     "python",
    --     "query",
    --     "regex",
    --     "tsx",
    --     "typescript",
    --     "jsdoc",
    --     "vim",
    --     "yaml",
    --   },
    -- },
  },

  -- treesitter playground
  { "nvim-treesitter/playground", lazy = true },

  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {
      enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
      max_lines = 0, -- How many lines the window should span. Values <= 0 mean no limit.
      min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
      line_numbers = true,
      multiline_threshold = 20, -- Maximum number of lines to show for a single context
      trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
      mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
      -- Separator between context and content. Should be a single character string, like '-'.
      -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
      separator = nil,
      zindex = 20, -- The Z-index of the context window
      on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
    },
  },

  -- treesitter textobjects
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
    enabled = true,
    config = function()
      -- If treesitter is already loaded, we need to run config again for textobjects
      if common_utils.is_loaded("nvim-treesitter") then
        local opts = common_utils.get_plugin_opts("nvim-treesitter")
        require("nvim-treesitter.configs").setup({ textobjects = opts.textobjects })
      end

      -- When in diff mode, we want to use the default
      -- vim text objects c & C instead of the treesitter ones.
      local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
      local configs = require("nvim-treesitter.configs")
      for name, fn in pairs(move) do
        if name:find("goto") == 1 then
          move[name] = function(q, ...)
            if vim.wo.diff then
              local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
              for key, query in pairs(config or {}) do
                if q == query and key:find("[%]%[][cC]") then
                  vim.cmd("normal! " .. key)
                  return
                end
              end
            end
            return fn(q, ...)
          end
        end
      end
    end,
  },

  -- Automatically add closing tags for HTML and JSX
  {
    "windwp/nvim-ts-autotag",
    opts = {},
  },
}

local Util = require("lazyvim.util")

local function telescope_buffer_dir()
  return vim.fn.expand("%:p:h")
end

return {
  {
    "telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },

    keys = function()
      return {
        {
          "<leader>,",
          "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>",
          desc = "Switch Buffer",
        },
        { "<leader>/", "<cmd>Telescope live_grep<cr>", desc = "Grep" },
        { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
        { "<leader><space>", Util.pick("files"), desc = "Find Files (root dir)" },

        -- find
        { "<leader>fb", "<cmd>Telescope buffers sort_mru=true sort_lastused=true<cr>", desc = "Buffers" },
        { "<leader>fc", Util.pick.config_files(), desc = "Find Config File" },
        { "<leader>ff", Util.pick("files"), desc = "Find Files (root dir)" },
        { "<leader>fF", Util.pick("files", { cwd = nil }), desc = "Find Files (cwd)" },
        { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent" },
        { "<leader>fR", Util.pick("oldfiles", { cwd = vim.loop.cwd() }), desc = "Recent (cwd)" },

        -- git
        { "<leader>gc", "<cmd>Telescope git_commits<CR>", desc = "commits" },
        { "<leader>gs", "<cmd>Telescope git_status<CR>", desc = "status" },

        -- search
        { '<leader>s"', "<cmd>Telescope registers<cr>", desc = "Registers" },
        { "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "Auto Commands" },
        { "<leader>sb", "<cmd>Telescope current_buffer_fuzzy_find<cr>", desc = "Buffer" },
        { "<leader>sc", "<cmd>Telescope command_history<cr>", desc = "Command History" },
        { "<leader>sC", "<cmd>Telescope commands<cr>", desc = "Commands" },
        { "<leader>sd", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document diagnostics" },
        { "<leader>sD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace diagnostics" },
        { "<leader>sg", Util.pick("live_grep"), desc = "Grep (root dir)" },
        { "<leader>sG", Util.pick("live_grep", { cwd = nil }), desc = "Grep (cwd)" },
        { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help Pages" },
        { "<leader>sH", "<cmd>Telescope highlights<cr>", desc = "Search Highlight Groups" },
        { "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "Key Maps" },
        { "<leader>sM", "<cmd>Telescope man_pages<cr>", desc = "Man Pages" },
        { "<leader>sm", "<cmd>Telescope marks<cr>", desc = "Jump to Mark" },
        { "<leader>so", "<cmd>Telescope vim_options<cr>", desc = "Options" },
        -- { "<leader>sr", "<cmd>Telescope resume<cr>", desc = "Resume" },
        -- { "<leader>sR", "<cmd>Telescope resume<cr>", desc = "Resume" },
        { "<leader>sw", Util.pick("grep_string", { word_match = "-w" }), desc = "Word (root dir)" },
        { "<leader>sW", Util.pick("grep_string", { cwd = nil, word_match = "-w" }), desc = "Word (cwd)" },
        { "<leader>sw", Util.pick("grep_string"), mode = "v", desc = "Selection (root dir)" },
        { "<leader>sW", Util.pick("grep_string", { cwd = nil }), mode = "v", desc = "Selection (cwd)" },
        { "<leader>uC", Util.pick("colorscheme", { enable_preview = true }), desc = "Colorscheme with preview" },
        {
          "<leader>ss",
          function()
            require("telescope.builtin").lsp_document_symbols({
              symbols = require("lazyvim.config").get_kind_filter(),
            })
          end,
          desc = "Goto Symbol",
        },
        {
          "<leader>sS",
          function()
            require("telescope.builtin").lsp_dynamic_workspace_symbols({
              symbols = require("lazyvim.config").get_kind_filter(),
            })
          end,
          desc = "Goto Symbol (Workspace)",
        },

        {
          "<leader>e",
          function()
            local telescope = require("telescope")
            telescope.extensions.file_browser.file_browser({
              path = "%:p:h",
              cwd = telescope_buffer_dir(),
              respect_gitignore = false,
              -- hidden = true,
              grouped = true,
              -- previewer = false,
              -- initial_mode = "normal",
              layout_config = { height = 40 },
            })
          end,
          desc = "Open File Browser with the path of the current buffer",
        },

        {
          "<leader>fP",
          function()
            require("telescope.builtin").find_files({
              cwd = require("lazy.core.config").options.root,
            })
          end,
          desc = "Find Plugin File",
        },

        {
          "<leader>;f",
          function()
            local builtin = require("telescope.builtin")
            builtin.find_files({
              no_ignore = false,
              hidden = true,
            })
          end,
          desc = "Lists files in your current working directory, respects .gitignore",
        },

        {
          "<leader>;b",
          function()
            local builtin = require("telescope.builtin")
            builtin.buffers()
          end,
          desc = "Lists open buffers",
        },

        {
          "<leader>;t",
          function()
            local builtin = require("telescope.builtin")
            builtin.help_tags()
          end,
          desc = "Lists available help tags and opens a new window with the relevant help info on <cr>",
        },

        {
          "<leader>;;",
          function()
            local builtin = require("telescope.builtin")
            builtin.resume()
          end,
          desc = "Resume the previous telescope picker",
        },

        {
          "<leader>;e",
          function()
            local builtin = require("telescope.builtin")
            builtin.diagnostics()
          end,
          desc = "Lists Diagnostics for all open buffers or a specific buffer",
        },

        {
          "<leader>;s",
          function()
            local builtin = require("telescope.builtin")
            builtin.treesitter()
          end,
          desc = "Lists Function names, variables, from Treesitter",
        },
      }
    end,

    config = function(_, opts)
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local fb_actions = require("telescope").extensions.file_browser.actions

      opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
        wrap_results = true,
        layout_strategy = "vertical", -- :h telescope.layout
        layout_config = { prompt_position = "top" },
        sorting_strategy = "ascending",
        winblend = 0,
        mappings = {
          n = {},
        },
      })

      opts.pickers = {
        diagnostics = {
          theme = "ivy",
          initial_mode = "normal",
          layout_config = {
            preview_cutoff = 9999,
          },
        },
      }

      opts.extensions = {
        file_browser = {
          -- theme = "dropdown",
          -- disables netrw and use telescope-file-browser in its place
          hijack_netrw = true,
          mappings = {
            ["n"] = {
              -- your custom normal mode mappings
              ["N"] = fb_actions.create,
              ["H"] = fb_actions.goto_parent_dir,
              ["h"] = fb_actions.toggle_hidden,
              ["/"] = function()
                vim.cmd("startinsert")
              end,
              ["<C-u>"] = function(prompt_bufnr)
                for i = 1, 10 do
                  actions.move_selection_previous(prompt_bufnr)
                end
              end,
              ["<C-d>"] = function(prompt_bufnr)
                for i = 1, 10 do
                  actions.move_selection_next(prompt_bufnr)
                end
              end,
              ["<PageUp>"] = actions.preview_scrolling_up,
              ["<PageDown>"] = actions.preview_scrolling_down,
            },
          },
        },
      }

      telescope.setup(opts)

      require("telescope").load_extension("fzf")
    end,
  },

  -- for some reason, file browser doesn't replace netrw when
  -- it's not individually added
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").load_extension("file_browser")
    end,
  },

  -- necessary for select menus like lsp code actions
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").setup({
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown({}),
          },
        },
      })
      require("telescope").load_extension("ui-select")
    end,
  },
}

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local conf = require("telescope.config").values

local live_multigrep = function(opts)
  opts = opts or {}
  opts.cwd = opts.cwd or vim.uv.cwd()

  local finder = finders.new_async_job({
    command_generator = function(prompt)
      if not prompt or prompt == "" then
        return nil
      end

      local pieces = vim.split(prompt, "  ")
      local args = { "rg" }

      if pieces[1] then
        table.insert(args, "-e")
        table.insert(args, pieces[1])
      end

      if pieces[2] then
        table.insert(args, "-g")
        table.insert(args, pieces[2])
      end

      return vim
        .iter({
          args,
          { "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
        })
        :flatten()
        :totable()
    end,
    entry_maker = make_entry.gen_from_vimgrep(opts),
    cwd = opts.cwd,
  })

  -- to use a theme, you can generate the opts using
  -- require("telescope.themes").get_<theme name>({<opts table>})
  local picker_opts = {
    -- Custom options for the picker
    debounce = 100,
    prompt_title = "Multi Grep",
    finder = finder,
    ---@diagnostic disable-next-line: no-unknown
    previewer = conf.grep_previewer(opts),
    ---@diagnostic disable-next-line: no-unknown
    sorter = require("telescope.sorters").empty(),
  }

  pickers.new(picker_opts, {}):find()
end

return live_multigrep

-- to make this a plugin
-- create a table, add a setup function, and return the table
--
-- local M = {}
--
-- M.setup = function(opts)
--   live_multigrep(opts)
-- end
--
-- return M

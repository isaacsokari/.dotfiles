return {
  -- search/replace in multiple files
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    opts = { open_cmd = "noswapfile vnew" },
    -- stylua: ignore
    keys = function()
      -- replaces all default keys
      return {
        { "<leader>sR", function() require("spectre").open() end, desc = "Replace in files (Spectre)" },
      }
    end
  },

}

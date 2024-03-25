return {
  { "rose-pine/neovim", name = "rose-pine" },

  -- Configure LazyVim to load rose-pine
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "rose-pine",
      colorscheme = "catppuccin",
      -- colorscheme = "tokyonight",
    },
    config = function(_, opts)
      require("lazyvim").setup(opts)

      vim.api.nvim_set_hl(0, "Folded", { link = "FoldColumn" })
    end,
  },
}

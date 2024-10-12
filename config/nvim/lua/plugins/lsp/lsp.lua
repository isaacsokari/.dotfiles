return {
  -- lsp/linter/formatter package manager
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "css-lsp",
        "shfmt",
        "stylua",
        "tailwindcss-language-server",
        "vtsls",
      })
    end,
  },

  -- lsp servers
  {
    "neovim/nvim-lspconfig",
    opts = {

      -- Enable this to enable the builtin LSP inlay hints on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the inlay hints.
      inlay_hints = {
        enabled = true,

        -- filetypes for which you don't want to enable inlay hints
        exclude = {},
      },

      -- Enable this to enable the builtin LSP code lenses on Neovim >= 0.10.0
      -- Be aware that you also will need to properly configure your LSP server to
      -- provide the code lenses.
      codelens = {
        enabled = false,
      },

      servers = {
        cssls = {},

        html = {},

        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
            },
          },
        },
      },

      setup = {},
    },
  },
}

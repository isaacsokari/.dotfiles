return {

  {
    "neovim/nvim-lspconfig",
    opts = {

      servers = {
        gopls = {
          settings = {
            gopls = {
              codelenses = {
                generate = false, -- Don't show the `go generate` lens.
                gc_details = true, -- Show a code lens toggling the display of gc's choices.
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },

              -- disable adding placeholders to completion
              usePlaceholders = false,

              hints = {
                -- @see https://github.com/golang/tools/blob/master/gopls/doc/inlayHints.md
                assignVariableTypes = false,
                compositeLiteralFields = true,
                compositeLiteralTypes = false,
                constantValues = true,
                functionTypeParameters = false,
                parameterNames = true,
                rangeVariableTypes = true,
              },
            },
          },
        },
      },

      setup = {},
    },
  },
}

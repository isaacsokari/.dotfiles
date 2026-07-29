return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				tailwindcss = {
					root_dir = function(bufnr, on_dir)
						local root = vim.fs.root(bufnr, ".git")
						if root then
							on_dir(root)
						end
					end,
				},
			},
		},
	},
}

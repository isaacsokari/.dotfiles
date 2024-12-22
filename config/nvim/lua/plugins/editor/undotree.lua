return {
	"mbbill/undotree",
	config = function()
		vim.keymap.set("n", "<leader>cu", "<Cmd>UndotreeToggle<CR>", { desc = "Toggle Undotree" })
	end,
}

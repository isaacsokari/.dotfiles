-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

-- fix conceallevel for json files
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc", "markdown" },
  callback = function()
    vim.wo.spell = false
    vim.wo.conceallevel = 0
  end,
})

-- add svg paste keymap for necessary filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = {
    "svg",
    "html",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "markdown",
  },

  callback = function()
    vim.keymap.set(
      { "n", "v" },
      "<leader>vs",
      [[Vpf>i<space>aria-hidden="true"<Esc>$]],
      { buffer = 0, desc = "Paste SVG (Replace Line)" }
    )
  end,
})

local is_env_file = function(e)
  local start_idx, _ = string.find(e.file, ".env", 1, true)
  return (start_idx or 0) == 1
end

vim.api.nvim_create_autocmd({ "BufNew", "BufNewFile" }, {
  pattern = "*",
  callback = function(e)
    if is_env_file(e) then
      vim.bo[e.buf].filetype = "sh"
      vim.diagnostic.enable(false, { bufnr = e.buf })
    end
  end,
})

-- disable diagnostics
vim.api.nvim_create_autocmd("FileType", {
  pattern = "sh",
  callback = function(e)
    if is_env_file(e) then
      vim.diagnostic.enable(false, { bufnr = e.buf })
    end
  end,
})

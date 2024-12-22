local ls = require("luasnip")

ls.add_snippets("javascript", {
	ls.parser.parse_snippet("clg", "console.log($1);"),
	ls.parser.parse_snippet("slog", "console.log(JSON.stringify($1, null, 2));"),
	ls.parser.parse_snippet("splog", "console.log('\\n', JSON.stringify($1, null, 2), '\\n');"),
	ls.parser.parse_snippet("nlog", "console.log('\\n', $1, '\\n');"),
})

local similar_filetypes = {
	"javascriptreact",
	"typescript",
	"typescriptreact",
}

for _, v in ipairs(similar_filetypes) do
	ls.filetype_extend(v, { "javascript" })
end

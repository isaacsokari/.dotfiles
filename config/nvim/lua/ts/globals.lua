P = function(value)
	if type(value) == "table" then
		print(vim.inspect(value))
	else
		print(value)
	end

	return value
end

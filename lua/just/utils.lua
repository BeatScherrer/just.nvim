local M = {}

function M.printTable(argument)
	print(vim.inspect(argument))
end

function M.reloadPlugin()
	require("plenary.reload").reload_module("just")
end

function M.splitString(input, separator)
	local words = {}
	for word in string.gmatch(input, "([^" .. separator .. "]+)") do
		table.insert(words, word)
	end
	return words
end

return M

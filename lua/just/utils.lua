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

function M.openQuickfix()
	vim.api.nvim_command("copen")
end

function M.appendToQuickfix(arg)
	vim.fn.setqflist({}, "a", {
		lines = arg,
		-- efm = "./%f: line %l: %m",
		efm = "%f: line %l: %m, error: Recipe %m failed on line %l",
	})
end

function M.sanitize(lines)
	for i = 1, #lines do
		lines[i] = (lines[i]):gsub(string.char(27) .. "[[0-9;]*m]", "")
	end
end

return M

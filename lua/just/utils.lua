local M = {}

---comment Helper to print a table.
---@param argument table Table to print.
function M.printTable(argument)
	print(vim.inspect(argument))
end

---comment Reloads the plugin.
function M.reloadPlugin()
	require("plenary.reload").reload_module("just")
end

---comment Splits a string by a given delimiter.
---@param input string Text to split.
---@param separator string Delimiter at which the splits are made.
---@return table Table of split strings.
function M.splitString(input, separator)
	local words = {}
	for word in string.gmatch(input, "([^" .. separator .. "]+)") do
		table.insert(words, word)
	end
	return words
end

---comment Opens the quickfix window.
function M.openQuickfix()
	vim.api.nvim_command("copen")
end

---comment Clears the quickfix window.
function M.clearQuickfix()
	print("clearing quickfix")
	vim.fn.setqflist({}, "r")
end

---comment Appends items to the quickfix list.
---@param arg any Arguments to add to the quickfix list.
function M.appendToQuickfix(arg)
	print("appending to quickfix: " .. arg)
	local item = {
		text = arg,
	}
	vim.fn.setqflist({ item }, "a")
end

---Sets the quickfix list title.
---@param arg any Title of the quickfix window.
function M.setQuickfixTitle(arg)
	vim.fn.setqflist({}, "a", {
		title = arg,
	})
end

---comment Removes color codes from a string
---@param lines string String to sanitize.
function M.sanitize(lines)
	for i = 1, #lines do
		lines[i] = (lines[i]):gsub(string.char(27) .. "[[0-9;]*m]", "")
	end
end

return M

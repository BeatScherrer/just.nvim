local M = {}

---Helper to print a table.
---@param argument table Table to print.
function M.printTable(argument)
	print(vim.inspect(argument))
end

---Runs a vim command silently and redraws.
---@param command string Vim command to execute.
function M.silentCommand(command)
	vim.api.nvim_command("silent " .. command)
	-- vim.api.nvim_command(command)
	vim.api.nvim_command("redraw!")
end

---Reloads the plugin.
function M.reloadPlugin()
	require("plenary.reload").reload_module("just")
end

---Splits a string by a given delimiter.
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

---Opens the quickfix window.
---@param filename string Optional name of the error file.
function M.openQuickfix(filename)
	if not filename then
		vim.api.nvim_command("copen")
	else
		-- vim.api.nvim_command("cfile " .. filename)
		M.silentCommand("cfile " .. filename)
		vim.api.nvim_command("copen")
	end
end

---Clears the quickfix window.
function M.clearQuickfix()
	vim.fn.setqflist({}, "r")
end

---Appends items to the quickfix list.
---@param arg any Arguments to add to the quickfix list.
function M.appendToQuickfix(arg)
	local item = {
		text = arg,
		-- pattern = vim.opt.errorformat._value,
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

---Removes color codes from a string
---@param lines string String to sanitize.
function M.sanitize(lines)
	for i = 1, #lines do
		lines[i] = (lines[i]):gsub(string.char(27) .. "[[0-9;]*m]", "")
	end
end

---Appends @param arg to the file @param file
---@param file string Name of the file.
---@param arg string Contect to append to the file @param file.
function M.appendToFile(file, arg)
	local out = io.open(file, "a")
	if out then
		out:write(arg)
		out:write("\n")
		out:close()
	else
		vim.notify("could not open file: " .. file)
	end
end

---Clears the content of the file @param file.
---@param file string Path of the file to clear.
function M.clearFile(file)
	local out = io.open(file, "w")
	if out then
		out:write()
	end
end

function M.openFloatingWindow()
	-- TODO: some parts of this function can be extracted
	local ui = vim.api.nvim_list_uis()[1]

	if not ui then
		vim.notify("could not retrieve the dimensions of the current ui!")
		return
	end

	local win_width = 50
	local win_height = 10

	local win_row = math.floor((ui.height - win_height) / 2)
	local win_col = math.floor((ui.width - win_width) / 2)

	local options = {
		relative = "editor",
		width = win_width,
		height = win_height,
		row = win_row,
		col = win_col,
		anchor = "NW",
		style = "minimal",
	}

	-- create a new buffer
	local buf = vim.api.nvim_create_buf(false, true)

	-- TODO make border configurable
	-- set the border
	local border_char = "─"
	local lines = {}

	-- add top border
	local top_line = "╭" .. string.rep(border_char, win_width - 2) .. "╮"
	local middle_line = "│" .. string.rep(" ", win_width - 2) .. "│"
	local bottom_line = "╰" .. string.rep(border_char, win_width - 2) .. "╯"

	table.insert(lines, top_line)
	for _ = 2, win_height - 1 do
		table.insert(lines, middle_line)
	end
	table.insert(lines, bottom_line)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	vim.api.nvim_open_win(buf, true, options)

	return buf
end

function M.openInput()
	-- TODO pass on actions and data to the floating window
	M.openFloatingWindow()
end

return M

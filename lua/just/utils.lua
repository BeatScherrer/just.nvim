local strings = require("plenary.strings")
local popup = require("plenary.popup")

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

function M.repeatedTable(n, val)
	local empty_lines = {}
	for _ = 1, n do
		table.insert(empty_lines, val)
	end

	return empty_lines
end

function M.openFloatingWindow(width, height, opts)
	opts = opts or {}
	opts.normal_hl = vim.F.if_nil(opts.normal_hl, "JustPrompt")
	opts.border_hl = vim.F.if_nil(opts.border_hl, "JustPromptBorder")
	opts.winblend = vim.F.if_nil(opts.winblend, 1)

	local popup_opts = {
		title = { { text = "Just input prompt", pos = "S" } },
		relative = "editor",
		enter = true,
		minheight = height,
		minwidth = width,
		noautocmd = true,
		border = { 0, 0, 0, 0 },
		borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
	}

	local win_id, win_opts = popup.create("", popup_opts)
	local buf = vim.api.nvim_win_get_buf(win_id)
	vim.api.nvim_buf_set_name(buf, "_JustInputPrompt")
	vim.api.nvim_buf_set_name(win_opts.border.bufnr, "_JustInputPromptBorder")
	vim.api.nvim_win_set_option(win_id, "winhl", "Normal:" .. opts.normal_hl)
	vim.api.nvim_win_set_option(win_opts.border.win_id, "winhl", "Normal:" .. opts.border_hl)
	vim.api.nvim_win_set_option(win_id, "winblend", opts.winblend)
	vim.api.nvim_win_set_option(win_id, "foldenable", false)

	vim.api.nvim_create_autocmd("BufLeave", {
		buffer = buf,
		once = true,
		callback = function()
			pcall(vim.api.nvim_win_close, win_id, true)
			pcall(vim.api.nvim_win_close, win_opts.border.win_id, true)
			M.deleteBuffer(buf)
		end,
	})

	-- vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "123456", "12", "123" })

	return win_id, win_opts
end

function M.deleteBuffer(buffer)
	if buffer == nil then
		return false
	else
		-- Suppress the buffer deleted message for those with &report<2
		local start_report = vim.o.report
		if start_report < 2 then
			vim.o.report = 2
		end

		if vim.api.nvim_buf_is_valid(buffer) and vim.api.nvim_buf_is_loaded(buffer) then
			vim.api.nvim_buf_delete(buffer, { force = true })
		end

		if start_report < 2 then
			vim.o.report = start_report
		end
	end
end

function M.openInput()
	-- TODO pass on actions and data to the floating window
	M.openFloatingWindow(50, 10)
end

return M

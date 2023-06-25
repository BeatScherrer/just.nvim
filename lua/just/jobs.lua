local utils = require("just.utils")
local Job = require("plenary.job")

local M = {}

---Get a list of the just summary (i.e. just recipes)
---@return table List containing just summary
M.justSummary = function()
	-- TODO handle case where no justfile is present
	local justRecipes = Job:new({
		command = "just",
		args = { "--summary" },
	}):sync()
	return utils.splitString(justRecipes[1], " ")
end

---Returns a list with the available just recipes.
---@return unknown List of the just recipe names.
M.justList = function()
	local list = Job:new({
		command = "just",
		args = { "--list" },
	}):sync()
	return list
end

---Runs a just recipe asynchronously.
---@param recipeName any Recipe name to run.
---@param autoStart any Whether the job should ran automatically (default=true)
---@return unknown Job handle
M.justRunAsync = function(recipeName, autoStart)
	if autoStart == nil then
		autoStart = true
	end

	-- TODO make this
	local filename = "/tmp/just_" .. recipeName .. ".txt"

	utils.clearFile(filename)

	local job = Job:new({
		command = "just",
		args = { recipeName },
		on_stdout = vim.schedule_wrap(function(_, lines)
			utils.appendToFile(filename, lines)
		end),
		on_stderr = vim.schedule_wrap(function(_, lines)
			utils.appendToFile(filename, lines)
		end),
		on_exit = vim.schedule_wrap(function(_, return_val)
			if return_val == 0 then
				print("success: " .. recipeName)
			else
				print("failed: " .. recipeName)
				-- TODO make opening quickfix automatically configurable
				utils.openQuickfix(filename)
			end
		end),
	})

	if autoStart then
		job:start()
	end

	return job
end

return M

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
---@return List of the just recipe names together with the arguments.
M.justList = function()
	-- TODO: this could probably be done more elegantly
	local justRecipes = {}

	local list = Job:new({
		command = "just",
		args = { "--list" },
	}):sync()

	-- remove first entry with 'Available recipes':
	table.remove(list, 1)

	for i, v in pairs(list) do
		local leading_ws = string.match(v, "^%s+")
		v = string.sub(v, #leading_ws + 1)

		-- split the sanitized string again to get the arguments
		local recipe_parts = utils.splitString(v, " ")

		-- add the recipe key
		justRecipes[recipe_parts[1]] = { arguments = {} }

		-- add the arguments to the recipe
		for i, word in pairs(recipe_parts) do
			if i ~= 1 then
				table.insert(justRecipes[recipe_parts[1]].arguments, word)
			end
		end
	end

	return justRecipes
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

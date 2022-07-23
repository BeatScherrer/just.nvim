local Job = require("plenary.job")

local utils = require("just.utils")

local M = {}

local justSummary = Job:new({
	command = "just",
	args = { "--summary" },
})

local justList = Job:new({
	command = "just",
	args = { "--list" },
})

M.setup = function(opts)
	vim.api.nvim_create_user_command("Just", function(opts)
		justSummary:sync()
		utils.printTable(justSummary:result())
	end, {
		nargs = "*",
		complete = function()
			justSummary:sync() -- or start()
			return utils.splitString(justSummary:result()[1], " ")
		end,
	})

	--
	-- 	end, { bang = true })
end

return M

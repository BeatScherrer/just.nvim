-- note: to run the picker for testing just call `luafile %`
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local config = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local jobs = require("just.jobs")

local M = {}

M.recipePicker = function(opts)
	opts = opts or {}

	pickers
		.new(opts, {
			prompt_tile = "Just Recipes",
			finder = finders.new_table(jobs.justSummary()),
			sorter = config.generic_sorter(opts),
			attach_mappings = function(prompt_bufnr, _)
				-- Select Default
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					jobs.justRunAsync(selection[1])
				end)
				return true
			end,
		})
		:find()
end

--M.recipePicker() --use this for debugging this file directly

return M

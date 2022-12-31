-- note: to run the picker for testing just call `luafile %`
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local config = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local jobs = require("just.jobs")
local utils = require("just.utils")

local M = {}

M.recipePicker = function(opts)
	opts = opts or {}

	-- get the recipes
	local recipes = jobs.justList()

	-- construct a list of recipes together with the arguments
	local recipeList = {}
	for recipe, v in pairs(recipes) do
		local args = ""

		-- utils.printTable(recipes)
		-- utils.printTable(v.arguments)
		if #v.arguments ~= 0 then
			for _, arg in pairs(v.arguments) do
				args = args .. " " .. arg
			end
			table.insert(recipeList, recipe .. ": " .. args)
		else
			table.insert(recipeList, recipe)
		end
	end

	utils.printTable(recipes)

	pickers
		.new(opts, {
			prompt_tile = "Just Recipes",
			finder = finders.new_table({
				results = recipes,
				entry_maker = function(entry)
					return { value = entry, display = entry.name, ordinal = entry.name }
				end,
			}),
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

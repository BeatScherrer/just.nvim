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

    local entry_maker = function(entry)
        local arguments = ""
        for _, v in ipairs(entry.arguments) do
            arguments = arguments .. " " .. v
        end

        local value = entry
        local display = ""

        if #entry.arguments ~= 0 then
            display = entry.name .. ": " .. arguments
        else
            display = entry.name
        end

        return {
            value = value,
            display = display,
            ordinal = display,
        }
    end

    pickers
        .new(opts, {
            prompt_tile = "Just Recipes",
            finder = finders.new_table({
                results = recipes,
                entry_maker = entry_maker,
            }),
            sorter = config.generic_sorter(opts),
            attach_mappings = function(prompt_bufnr, _)
                -- Select Default
                actions.select_default:replace(function()
                    actions.close(prompt_bufnr)
                    local selection = action_state.get_selected_entry()

                    local arguments = {}
                    for _, v in ipairs(selection.value.arguments) do
                        -- TODO: enable input popup configurable
                        -- local argument = utils.openInput()
                        local argument = vim.fn.input(v .. ": ")

                        arguments[v] = argument
                    end

                    jobs.justRunAsync(selection.value.name, arguments)
                end)
                return true
            end,
        })
        :find()
end

--M.recipePicker() --use this for debugging this file directly

return M

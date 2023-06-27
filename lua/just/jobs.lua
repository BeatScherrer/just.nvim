local log = require("just.log")
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
---@return table of the just recipe names together with the arguments.
M.justList = function()
    local justRecipes = {}

    local list = Job:new({
        command = "just",
        args = { "--list" },
    }):sync()

    -- remove first entry with 'Available recipes':
    table.remove(list, 1)

    for _, v in pairs(list) do
        local comment = ""

        v = utils.trimLeadingWhitespace(v)

       -- split off the comments
        local recipe_parts = utils.splitString(v, "#")
        if #recipe_parts > 1 then
            comment = utils.trimLeadingWhitespace(recipe_parts[2])
        end

        recipe_parts = utils.splitString(recipe_parts[1], " ")
        local recipe_name = recipe_parts[1]
        local arguments = {unpack(recipe_parts, 2)}

        -- add the recipe table
        local recipe = { name = recipe_name, arguments = arguments, comment = comment }

        table.insert(justRecipes, recipe)
    end

    log.debug(vim.inspect(justRecipes), {})
    return justRecipes
end

---Runs a just recipe asynchronously.
---@param recipeName any Recipe name to run.
---@param autoStart any Whether the job should ran automatically (default=true)
---@return unknown Job handle
M.justRunAsync = function(recipeName, recipeArgs, autoStart)
    if autoStart == nil then
        autoStart = true
    end

    recipeArgs = recipeArgs or {}

    local filename = "/tmp/just_" .. recipeName .. ".txt"

    utils.clearFile(filename)

    local justArgs = {}
    table.insert(justArgs, recipeName)

    for _, v in pairs(recipeArgs) do
        table.insert(justArgs, v)
    end

    local job = Job:new({
        command = "just",
        args = justArgs,
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

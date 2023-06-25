-- TODO: add docs

local M = {}

--- Log with level DEBUG
---@param message string message to log.
---@param opts table options.
function M.debug(message, opts)
    vim.notify("just: " .. message, vim.log.levels.DEBUG, opts)
end

--- Log with level INFO
---@param message string message to log.
---@param opts table options.
function M.info(message, opts)
    vim.notify("just: " .. message, vim.log.levels.INFO, opts)
end

--- Log with level WARN
---@param message string message to log.
---@param opts table options.
function M.warn(message, opts)
    vim.notify("just: " .. message, vim.log.levels.WARN, opts)
end

--- Log with level ERROR
---@param message string message to log.
---@param opts table options.
function M.error(message, opts)
    vim.notify("just: " .. message, vim.log.levels.ERROR, opts)
end

return M

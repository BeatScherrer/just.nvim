local strings = require("plenary.strings")
local popup = require("plenary.popup")
local log = require("just.log")

local M = {}

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

--- Trims leading whitespaces of an input string
---@param input string to trim.
---@return string Trimmed input string
function M.trimLeadingWhitespace(input)
  local leading_ws = string.match(input, "^%s+")
  return string.sub(input, #leading_ws + 1)
end

--- Flattens a table to a string.
---@param tbl table to flatten
---@return string of the flattened table.
function M.flattenTable(tbl)
  local result = {}

  local function flattenHelper(subTable)
    for _, v in pairs(subTable) do
      if type(v) == "table" then
        flattenHelper(v)
      else
        result[#result + 1] = tostring(v)
      end
    end
  end

  flattenHelper(tbl)
  return table.concat(result, " ")
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
        log.warn("could not open file: " .. file)
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

function M.openFloatingWindow(width, height, opts, fillchar)
    -- Add a default parameters
    fillchar = vim.F.if_nil(fillchar, "/")
    opts = opts or {}
    opts.normal_hl = vim.F.if_nil(opts.normal_hl, "JustPrompt")
    opts.border_hl = vim.F.if_nil(opts.border_hl, "JustPromptBorder")
    opts.winblend = vim.F.if_nil(opts.winblend, 1)
    opts.border = vim.F.if_nil(opts.border, 0)

    local popup_opts = {
        title = { { text = "Just input prompt", pos = "N" } },
        relative = "editor",
        enter = opts.enter,
        minheight = height,
        minwidth = width,
        noautocmd = true,
        border = { opts.border, opts.border, opts.border, opts.border },
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        focusable = 1,
    }

    local win_id, win_opts = popup.create("", popup_opts)
    local buf = vim.api.nvim_win_get_buf(win_id)
    -- vim.api.nvim_buf_set_name(buf, "_JustInputPrompt")
    -- vim.api.nvim_buf_set_name(win_opts.border.bufnr, "_JustInputPromptBorder")
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
    local popupWindow, _ = M.openFloatingWindow(50, 5, { border = 1, enter = 0 })
    local promptWindow, _ = M.openFloatingWindow(20, 1, { border = 1, enter = 1 })

    local popupBuf = vim.api.nvim_win_get_buf(popupWindow)
    local promptBuf = vim.api.nvim_win_get_buf(promptWindow)

    print("popupBuf: " .. popupBuf)
    print("promptBuf: " .. promptBuf)

    -- close all windows when the prompt buffer is left
    vim.api.nvim_create_autocmd("BufLeave", {
        buffer = promptBuf,
        once = true,
        callback = function()
            pcall(vim.api.nvim_win_close, popupWindow, true)
            pcall(vim.api.nvim_win_close, promptWindow, true)
            -- pcall(vim.api.nvim_buf_delete(popupBuf, {}))
            -- pcall(vim.api.nvim_buf_delete(promptBuf, {}))
            -- TODO: Do we need to delete the buffers here??
        end,
    })
end

--- Gets the basename of a path.
-- That is the file name without the extension.
---@param path string Path of the file to get the basename for.
---@return string Basename of the file.
function M.basename(path)
    return path:match(".+/(.-)%..+$") or path
end

--- Retrieves a recipe by its name.
---@param name string Name of the recipe to get.
---@return table? Recipe with the requested name.
function M.getRecipeByName(name)
    local jobs = require("just.jobs")
    local recipes = jobs.justList()

    for _, v in pairs(recipes) do
        if name == v.name then
            return v
        end
    end

    return nil
end

return M

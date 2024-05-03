---@diagnostic disable: deprecated, duplicate-doc-field
---@mod telescope-manix.compat Functions for backward compatibility with older Neovim versions
---@brief [[

---WARNING: This is not part of the public API.
---Breaking changes to this module will not be reflected in the semantic versioning of this plugin.

---@brief ]]

local compat = {}

--- @class vim.SystemCompleted
--- @field code integer
--- @field signal integer
--- @field stdout? string
--- @field stderr? string

compat.system = vim.system
  -- wrapper around vim.fn.system to give it a similar API to vim.system
  or function(cmd, _, on_exit)
    local output = vim.fn.system(cmd)
    local ok = vim.v.shell_error
    ---@type vim.SystemCompleted
    local systemObj = {
      signal = 0,
      stdout = ok and (output or "") or nil,
      stderr = not ok and (output or "") or nil,
      code = vim.v.shell_error,
    }
    on_exit(systemObj)
    return systemObj
  end

---@type fun(tbl:table):table
compat.tbl_flatten = vim.iter and function(tbl)
  return vim.iter(tbl):flatten():totable()
end or vim.tbl_flatten

return compat

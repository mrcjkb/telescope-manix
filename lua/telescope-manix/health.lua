---@mod telescope-manix.health Health checks

---@brief [[

---WARNING: This is not part of the public API.
---Breaking changes to this module will not be reflected in the semantic versioning of this plugin.

---@brief ]]

local health = {}

local h = vim.health or require("health")
local start = h.start or h.report_start
local ok = h.ok or h.report_ok
local error = h.error or h.report_error
local warn = h.warn or h.report_warn

---@class LuaDependency
---@field module string The name of a module
---@field optional fun():boolean Function that returns whether the dependency is optional
---@field url string URL (markdown)
---@field info string Additional information

---@type LuaDependency[]
local lua_dependencies = {
  {
    module = "telescope",
    optional = function()
      return false
    end,
    url = "[nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)",
    info = "This plugin is a telescope extension",
  },
}

---@class ExternalDependency
---@field name string Name of the dependency
---@field get_binaries fun():string[]Function that returns the binaries to check for
---@field optional fun():boolean Function that returns whether the dependency is optional
---@field url string URL (markdown)
---@field info string Additional information
---@field extra_checks function|nil Optional extra checks to perform if the dependency is installed

---@type ExternalDependency[]
local external_dependencies = {
  {
    name = "manix",
    get_binaries = function()
      return { "manix" }
    end,
    optional = function()
      return false
    end,
    url = "[manix](https://github.com/mlvzk/manix)",
    info = "Required as a backend for the Nix documentation search.",
  },
}

---@param dep LuaDependency
local function check_lua_dependency(dep)
  local is_installed, _ = pcall(require, dep.module)
  if is_installed then
    ok(dep.url .. " installed.")
    return
  end
  if dep.optional() then
    warn(("%s not installed. %s %s"):format(dep.module, dep.info, dep.url))
  else
    error(("Lua dependency %s not found: %s"):format(dep.module, dep.url))
  end
end

---@param dep ExternalDependency
---@return boolean is_installed
---@return string|nil version
local check_installed = function(dep)
  local binaries = dep.get_binaries()
  for _, binary in ipairs(binaries) do
    if vim.fn.executable(binary) == 1 then
      local handle = io.popen(binary .. " --version")
      if handle then
        local binary_version, error_msg = handle:read("*a")
        handle:close()
        if error_msg then
          return true
        end
        return true, binary_version
      end
      return true
    end
  end
  return false
end

---@param dep ExternalDependency
local function check_external_dependency(dep)
  local installed, mb_version = check_installed(dep)
  if installed then
    local mb_version_newline_idx = mb_version and mb_version:find("\n")
    local mb_version_len = mb_version and (mb_version_newline_idx and mb_version_newline_idx - 1 or mb_version:len())
    local version = mb_version and mb_version:sub(0, mb_version_len) or "(unknown version)"
    ok(("%s: found %s"):format(dep.name, version))
    if dep.extra_checks then
      dep.extra_checks()
    end
    return
  end
  if dep.optional() then
    warn(([[
      %s: not found.
      Install %s for extended capabilities.
      %s
      ]]):format(dep.name, dep.url, dep.info))
  else
    error(([[
      %s: not found.
      haskell-tools.nvim requires %s.
      %s
      ]]):format(dep.name, dep.url, dep.info))
  end
end

function health.check()
  start("Checking for Lua dependencies")
  for _, dep in ipairs(lua_dependencies) do
    check_lua_dependency(dep)
  end

  start("Checking external dependencies")
  for _, dep in ipairs(external_dependencies) do
    check_external_dependency(dep)
  end
end

return health

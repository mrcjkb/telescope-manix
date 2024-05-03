---@mod telescope-manix Manix Telescope extension
---@brief [[
--- If `telescope.nvim` is installed, `haskell-tools` will register the `ht` extenstion
--- with the `:Telescope manix` command:
---
--- To load the extension, call
---
--- >
--- require('telescope').load_extension('manix')
--- <
---
--- In Lua, you can access the extension with
---
--- >
--- local telescope = require('telescope').extensions.manix.manix()
--- <
---@brief ]]

local has_telescope, pickers = pcall(require, "telescope.pickers")
if not has_telescope then
  error("telescope-manix requires nvim-telescope/telescope.nvim")
end

local compat = require("telescope-manix.compat")
local finders = require("telescope.finders")
local config = require("telescope.config").values
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local previewers = require("telescope.previewers")
local previewer_utils = require("telescope.previewers.utils")

local manix = {}

---@class ManixOpts
---@field manix_args string[] CLI arguments to pass to manix, see `manix --help`
---@field cword boolean Set to true to search for the word under the cursor

---@param opts ManixOpts
---@return string[] manix_cmd
local function mk_manix_cmd(opts)
  local search_arg = opts.cword and vim.fn.expand("<cword>") or ""
  local args = opts.manix_args or {}
  return compat.tbl_flatten({ "manix", search_arg, args })
end

---@param str string
---@param pattern string
---@return string[] matches
local function tmatch(str, pattern)
  local matches = {}
  for match in string.gmatch(str, pattern) do
    matches[#matches + 1] = match
  end
  return matches
end

---@param entry table
---@param buf integer
---@return nil
local function show_manix_preview(entry, buf)
  compat.system(
    { "manix", entry.display, "--strict" },
    nil,
    vim.schedule_wrap(function(sc)
      ---@cast sc vim.SystemCompleted
      local stdout = sc.stdout
      if sc.code ~= 0 or stdout == nil then
        vim.notify("Error querying manix for manix-telescope preview", vim.log.levels.ERROR)
        return
      end
      local manix_results = {}
      for line in stdout:gmatch("([^\n]*)\n?") do
        table.insert(manix_results, line)
      end
      if #manix_results > 0 then
        vim.api.nvim_buf_set_lines(buf, 0, -1, true, manix_results)
        previewer_utils.highlighter(buf, "nix")
        vim.api.nvim_buf_call(buf, function()
          local win = vim.fn.win_findbuf(buf)[1]
          vim.wo[win].conceallevel = 2
          vim.wo[win].wrap = true
          vim.wo[win].linebreak = true
          vim.bo[buf].textwidth = 80
        end)
      end
    end)
  )
end

---@param entry string
---@return table | nil manix_entry
local function mk_manix_entry(entry)
  local matches = tmatch(entry, "# ([%S]+)")
  if #matches == 0 then
    return nil
  end
  local display = matches[1]
  return {
    value = entry,
    display = display,
    ordinal = display,
    preview_command = show_manix_preview,
  }
end

---@param buf number
---@return boolean
local function attach_mappings(buf)
  actions.select_default:replace(function()
    local entry = actions_state.get_selected_entry()
    actions.close(buf)
    vim.api.nvim_put({ entry.display }, "", true, true)
  end)
  return true
end

---Search the Nix documentation
---@param opts ManixOpts|table The manix options and/or the options to pass to Telescope
manix.search = function(opts)
  if vim.fn.executable("manix") ~= 1 then
    vim.notify("telescope-manix: 'manix' executable not found! Aborting.", vim.log.levels.ERROR)
    return
  end
  opts = opts or {}
  opts.entry_maker = opts.entry_maker or mk_manix_entry
  pickers
    .new(opts, {
      prompt_title = "Nix search",
      finder = finders.new_oneshot_job(mk_manix_cmd(opts), opts),
      sorter = config.generic_sorter(opts),
      previewer = previewers.display_content.new(opts),
      attach_mappings = attach_mappings,
    })
    :find()
end

return manix

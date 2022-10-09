local has_telescope, pickers = pcall(require, 'telescope.pickers')
local finders = require('telescope.finders')
local config = require('telescope.config').values
local actions = require('telescope.actions')
local actions_state = require('telescope.actions.state')
local previewers = require('telescope.previewers')
local has_plenary, Job = pcall(require, 'plenary.job')

if not has_telescope then
  error('telescope-manix requires nvim-telescope/telescope.nvim')
end
if not has_plenary then
  error('telescope-manix requires nvim-lua/plenary.nvim')
end

local M = {}

local function mk_manix_cmd(opts)
  local args = opts.manix_args or {}
  return vim.tbl_flatten { 'manix', "", args, }
end

local function merge(...)
  return vim.tbl_extend('keep', ...)
end

local function tmatch(str, pattern)
  local matches = {}
  for match in string.gmatch(str, pattern) do
    matches[#matches+1] = match
  end
  return matches
end

local function show_manix_preview(entry, buf)
  Job:new({
    command = 'manix',
    args = { entry.display, '--strict'},
    on_exit = function(job, exit_code)
      vim.schedule(function()
        if exit_code ~= 0 then
          vim.notify('Error querying manix for manix-telescope previiew', vim.log.levels.ERROR)
          return
        end
        local manix_results = job:result()
        if manix_results then
          vim.api.nvim_buf_set_lines(buf, 0, -1, true, manix_results)
          vim.api.nvim_buf_call(buf, function()
            local win = vim.fn.win_findbuf(buf)[1]
            vim.wo[win].conceallevel = 2
            vim.wo[win].wrap = true
            vim.wo[win].linebreak = true
            vim.bo[buf].textwidth = 80
          end)
        end
      end)
    end
  }):start()
end

local function mk_manix_entry(entry)
  local matches = tmatch(entry, '# ([%S]+)')
  if #matches == 0 then
    return nil
  end
  local display = matches[1]
  return {
    value = entry,
    display = display,
    ordinal = display,
    preview_command = show_manix_preview
  }
end

local function attach_mappings(buf)
  actions.select_default:replace(function()
    local entry = actions_state.get_selected_entry()
    actions.close(buf)
    vim.api.nvim_put({ entry.display }, "", true, true)
  end)
  return true
end

M.search = function(opts)
  if vim.fn.executable('manix') == '1' then
    error("telescope-manix: 'manix' executable not found! Aborting.")
    return
  end
  opts = merge(opts or {}, {
    layout_strategy = 'horizontal',
    layout_config = { preview_width = 80 }
  })
  opts.entry_maker = opts.entry_maker or mk_manix_entry
  pickers.new(opts, {
    prompt_title = 'Nix search',
    finder = finders.new_oneshot_job(
      mk_manix_cmd(opts),
      opts
    ),
    sorter = config.generic_sorter(opts),
    previewer = previewers.display_content.new(opts),
    attach_mappings = attach_mappings,
  }):find()
end

return M

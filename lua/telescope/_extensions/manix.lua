local has_telescope, telescope = pcall(require, 'telescope')
if not has_telescope then
  error('This plugin requires nvim-telescope/telescope.nvim')
end

local manix = require 'telescope._extensions.manix.manix_search'

return telescope.register_extension {
  exports = { manix = manix }
}


local MODREV, SPECREV = 'scm', '-1'
rockspec_format = '3.0'
package = 'telescope-manix'
version = MODREV .. SPECREV

description = {
  summary = 'A telescope.nvim extension for manix',
  detailed = [[
    Manix is a fast documentation searcher for nix.
    This plugin provides a telescope.nvim extension for manix.
  ]],
  labels = { 'neovim', 'nix', 'plugin', 'telescope' },
  homepage = 'https://github.com/mrcjkb/telescope-manix',
  license = 'GPL-2.0',
}

dependencies = {
  'lua >= 5.1',
  'telescope.nvim',
}

source = {
  url = 'git://github.com/mrcjkb/telescope-manix',
}

build = {
  type = 'builtin',
}

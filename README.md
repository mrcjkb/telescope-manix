# telescope-manix

A [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) extension for [Manix](https://github.com/mlvzk/manix)
> A fast documentation searcher for [Nix](https://nixos.wiki/wiki/Overview_of_the_Nix_Language)

## Installation

* Depends on [Manix](https://github.com/mlvzk/manix).

Using packer:

```lua
use {
  'nvim-telescope/telescope.nvim`,
  requires = {
    'MrcJkb/telescope-manix',
  },
}

```

## Configuration

Add the following to your telescope config:

```lua
local telescope = require('telescope')
telescope.setup {
  -- opts...
}
telescope.load_extension('manix')
```

## Usage

```vim
:Telescope manix
```

```lua
require('telescope-manix').search()
```

## Customisation

```lua
default_opts = {
  -- CLI arguments to pass to manix, see `manix --help`
  manix_args = {},
}
require('telescope-manix').search(default_opts)
```

# telescope-manix


![Neovim](https://img.shields.io/badge/NeoVim-%2357A143.svg?&style=for-the-badge&logo=neovim&logoColor=white)
![Lua](https://img.shields.io/badge/lua-%232C2D72.svg?style=for-the-badge&logo=lua&logoColor=white)
![Nix](https://img.shields.io/badge/nix-0175C2?style=for-the-badge&logo=NixOS&logoColor=white)


A [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) extension for [Manix](https://github.com/mlvzk/manix)
> A fast documentation searcher for [Nix](https://nixos.wiki/wiki/Overview_of_the_Nix_Language)

## Quick links
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Customisation](#customisation)

## Features

#### Nix fuzzy search
[![asciicast](https://asciinema.org/a/t1rHXoElZtqW9lIhOamNG2xgu.svg)](https://asciinema.org/a/t1rHXoElZtqW9lIhOamNG2xgu)

#### Search for the word under the cursor
[![asciicast](https://asciinema.org/a/6FyS0Bkp7bqSYLvY4OwvxzOF7.svg)](https://asciinema.org/a/6FyS0Bkp7bqSYLvY4OwvxzOF7)

## Prerequisites

* Depends on [Manix](https://github.com/mlvzk/manix).
* [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)

## Installation

Using packer:

```lua
use {
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x', -- Recommended
  requires = {
    'nvim-lua/plenary.nvim',
    'MrcJkb/telescope-manix',
    -- ...
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
-- or
require('telescope').extensions.manix.manix()
```

## Customisation

```lua
default_opts = {
  -- CLI arguments to pass to manix, see `manix --help`
  -- for example: `{'--source', 'nixpkgs_doc', '--source', 'nixpkgs_comments'}`
  -- will restrict search to nixpkgs docs and comments.
  manix_args = {},
  -- Set to true to search for the word under the cursor
  cword = false,
}
require('telescope-manix').search(default_opts)
-- or
require('telescope').extensions.manix.manix(derault_opts)
```

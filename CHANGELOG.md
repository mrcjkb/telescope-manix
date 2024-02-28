<!-- markdownlint-disable -->
# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.2] - 2024-02-29
### Fixed
- Remove `vim.print` statement.

## [1.0.1] - 2024-02-29
### Fixed
- Notify if `manix` executable is not on `PATH`.

## [1.0.0] - 2023-10-29
### Changed
- POTENTIALLY BREAKING: Remove uses of `plenary.nvim`,
  [which may be removed as a dependency from `telescope.nvim`](https://github.com/nvim-telescope/telescope.nvim/issues/2552).
  NOTE: This should not break anything, but it may bump the minimum Neovim version requirement.
  The telescope picker may be a bit slower on Neovim 0.9.
  This will improve again with Neovim 0.10.
- Internal: Add type checks for `neovim stable` and `neovim nightly`.

## [0.5.0] - 2023-09-04
### Added
- Helptags
- Health check

## [0.4.0] - 2023-02-03
### Changed
- Do not set a default layout for telescope Hoogle search.
### Added
- Rockspec
- LuaRocks release workflow

## [0.3.0] - 2022-10-19
### Added
- Add option to search for word under cursor

## [0.2.0] - 2022-10-19
### Added
- Attach `nix` highlighter to previewer

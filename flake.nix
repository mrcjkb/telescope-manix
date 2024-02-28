{
  description = "A telescope.nvim extension for Manix, a fast documentation searcher for Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    neorocks.url = "github:nvim-neorocks/neorocks";

    gen-luarc.url = "github:mrcjkb/nix-gen-luarc-json";

    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    neorocks,
    gen-luarc,
    pre-commit-hooks,
    flake-utils,
    ...
  }: let
    supportedSystems = [
      "aarch64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];

    plugin-overlay = import ./nix/plugin-overlay.nix {inherit self;};
  in
    flake-utils.lib.eachSystem supportedSystems (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          plugin-overlay
          neorocks.overlays.default
          gen-luarc.overlays.default
        ];
      };

      docgen = pkgs.callPackage ./nix/docgen.nix {};

      luarc-plugins = with pkgs.lua51Packages; [
        telescope-nvim
      ];

      luarc-nightly = pkgs.mk-luarc {
        nvim = pkgs.neovim-nightly;
        neodev-types = "nightly";
        plugins = luarc-plugins;
      };

      luarc-stable = pkgs.mk-luarc {
        nvim = pkgs.neovim-unwrapped;
        neodev-types = "stable";
        plugins = luarc-plugins;
        disabled-diagnostics = [
          "undefined-doc-name"
          "redundant-parameter"
          "invisible"
        ];
      };

      type-check-nightly = pre-commit-hooks.lib.${system}.run {
        src = self;
        hooks = {
          lua-ls.enable = true;
        };
        settings = {
          lua-ls.config = luarc-nightly;
        };
      };

      type-check-stable = pre-commit-hooks.lib.${system}.run {
        src = self;
        hooks = {
          lua-ls.enable = true;
        };
        settings = {
          lua-ls.config = luarc-stable;
        };
      };

      pre-commit-check = pre-commit-hooks.lib.${system}.run {
        src = self;
        hooks = {
          alejandra.enable = true;
          stylua.enable = true;
          luacheck.enable = true;
          editorconfig-checker.enable = true;
          markdownlint.enable = true;
        };
      };

      telescope-manix-shell = pkgs.mkShell {
        name = "telescope-manix-devShell";
        shellHook = ''
          ${pre-commit-check.shellHook}
          ln -fs ${pkgs.luarc-to-json luarc-nightly} .luarc.json
        '';
        buildInputs = with pre-commit-hooks.packages.${system}; [
          alejandra
          lua-language-server
          stylua
          luacheck
          editorconfig-checker
          markdownlint-cli
        ];
      };
    in {
      devShells = rec {
        default = telescope-manix;
        telescope-manix = telescope-manix-shell;
      };

      packages = rec {
        default = telescope-manix;
        inherit docgen;
        inherit
          (pkgs)
          telescope-manix
          ;
      };

      checks = {
        inherit
          pre-commit-check
          type-check-stable
          type-check-nightly
          ;
      };
    })
    // {
      overlays = {
        default = plugin-overlay;
      };
    };
}

{
  description = "A telescope.nvim extension for Manix, a fast documentation searcher for Nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    neorocks = {
      url = "github:nvim-neorocks/neorocks";
    };

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
        ];
      };

      docgen = pkgs.callPackage ./nix/docgen.nix {};

      mkTypeCheck = {
        nvim-api ? [],
        disabled-diagnostics ? [],
      }:
        pre-commit-hooks.lib.${system}.run {
          src = self;
          hooks = {
            lua-ls.enable = true;
          };
          settings = {
            lua-ls = {
              config = {
                runtime.version = "LuaJIT";
                Lua = {
                  workspace = {
                    library =
                      nvim-api
                      ++ [
                        "${pkgs.vimPlugins.telescope-nvim}/lua"
                      ];
                    checkThirdParty = false;
                    ignoreDir = [
                      ".git"
                      ".github"
                      ".direnv"
                      "result"
                      "nix"
                      "doc"
                    ];
                  };
                  diagnostics = {
                    libraryFiles = "Disable";
                    disable = disabled-diagnostics;
                  };
                };
              };
            };
          };
        };

      type-check-stable = mkTypeCheck {
        nvim-api = [
          "${pkgs.neovim}/share/nvim/runtime/lua"
          "${pkgs.vimPlugins.neodev-nvim}/types/stable"
        ];
        disabled-diagnostics = [
          "undefined-doc-name"
          "redundant-parameter"
          "invisible"
        ];
      };

      type-check-nightly = mkTypeCheck {
        nvim-api = [
          "${pkgs.neovim-nightly}/share/nvim/runtime/lua"
          "${pkgs.vimPlugins.neodev-nvim}/types/nightly"
        ];
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
        inherit (pre-commit-check) shellHook;
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

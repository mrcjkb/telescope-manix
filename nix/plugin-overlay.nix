{self}: final: prev: {
  telescope-manix = prev.vimUtils.buildVimPluginFrom2Nix {
    name = "telescope-manix.nvim";
    src = self;
  };
}

{self}: final: prev: {
  telescope-manix = prev.vimUtils.buildVimPlugin {
    name = "telescope-manix.nvim";
    src = self;
  };
}

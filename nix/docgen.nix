{pkgs, ...}:
pkgs.writeShellApplication {
  name = "docgen";
  runtimeInputs = with pkgs; [
    lemmy-help
  ];
  text = ''
    mkdir -p doc
    lemmy-help lua/telescope-manix/init.lua lua/telescope/_extensions/manix.lua > doc/telescope-manix.txt
  '';
}

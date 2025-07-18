{ ... }:

{
  imports = [
    ./programs/git.nix
    ./programs/shell.nix
    ./programs/terminal.nix
    ./programs/editor.nix
  ];

  home = {
    username = "nyaleph";
    homeDirectory = "/home/nyaleph";
    stateVersion = "25.05";
  };

  programs.home-manager.enable = true;
}

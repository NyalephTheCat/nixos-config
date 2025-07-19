{ config, pkgs, lib, ... }:

{
  imports = [ ./packages.nix ./programs ./services ];

  home = {
    username = "nyaleph";
    homeDirectory = "/home/nyaleph";
    stateVersion = "25.05";

    sessionVariables = {
      EDITOR = "nvim";
      BROWSER = "firefox";
      TERMINAL = "konsole";
    };
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Basic XDG configuration
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };
}

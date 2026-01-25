{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    # Application modules (organized by category)
    ./applications
    
    # Emulator modules
    ./emulators/default.nix
    
    # Terminal modules
    ./terminal/kitty.nix
    ./terminal/zsh.nix
    
    # Program modules
    ./programs/git.nix
  ];

  # Global home manager options
  home.stateVersion = "24.11";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;
}


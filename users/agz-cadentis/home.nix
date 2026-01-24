{ config, pkgs, lib, ... }:

{
  # Basic Home Manager settings
  home.username = "agz-cadentis";
  home.homeDirectory = "/home/agz-cadentis";
  home.stateVersion = "25.11"; # DO NOT CHANGE THIS

  # Enable Home Manager
  programs.home-manager.enable = true;

  # User feature flags - customize based on agz's preferences
  features.user = {
    gaming-tools = true; # Set to true if desired
    content-creation = true; # Set to true if desired
    streaming = true;
    development = true; # Set to true if desired
    libreoffice = true;
  };

  # Import shared Home Manager modules
  imports = [
    ../../modules/home-manager/programs
    ../../modules/home-manager/features
    ./packages.nix
  ];

  # Git user configuration - TODO: Update with actual values
  programs.git.userName = "agz";
  programs.git.userEmail = "agz@example.com"; # TODO: Update email

  # Terminal preference
  programs.kitty.enable = true; # Or alacritty

  # Starship and direnv are enabled by default from shared modules
}


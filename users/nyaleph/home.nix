{ config, pkgs, lib, ... }:

{
  # Basic Home Manager settings
  home.username = "nyaleph";
  home.homeDirectory = "/home/nyaleph";
  home.stateVersion = "25.11";

  # Enable Home Manager
  programs.home-manager.enable = true;

  # User feature flags
  features.user = {
    gaming-tools = true;
    content-creation = false;
    streaming = false;
    development = true;
    libreoffice = true;
  };

  # Import shared Home Manager modules
  imports = [
    ../../modules/home-manager/programs
    ../../modules/home-manager/features
    ./packages.nix
  ];

  # Git user configuration (using new settings format)
  programs.git.settings = {
    user.name = "nyaleph";
    user.email = "chloe@magnier.dev";
  };

  # Terminal preference
  programs.kitty.enable = true;

  # Starship and direnv are enabled by default from shared modules
}


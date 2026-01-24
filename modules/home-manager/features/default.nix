{ config, pkgs, lib, ... }:

{
  # Import options first, then feature modules
  imports = [
    ../options.nix  # Define features.user options
    ./gaming-tools.nix
    ./content-creation.nix
    ./streaming.nix
    ./development.nix
    ./libreoffice.nix
  ];
}


{ config, pkgs, lib, ... }:

{
  # Import all desktop environment modules
  # Each module uses lib.mkIf internally to conditionally enable based on features.desktop.environment
  imports = [
    ./plasma.nix
    ./gnome.nix
    ./themes.nix
    ./wallpapers.nix
  ];
}


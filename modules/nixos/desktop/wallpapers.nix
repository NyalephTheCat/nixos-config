{ config, pkgs, lib, ... }:

let
  # Check which desktop environment is enabled
  isGnome = (config.features.desktop.environment or "none") == "gnome";
  isPlasma = (config.features.desktop.environment or "none") == "plasma";
  sharedWallpapersPath = ../../../../shared/wallpapers;
in
{
  config = lib.mkIf (isGnome || isPlasma) {
    # Wallpaper packages (if any are packaged)
    environment.systemPackages = with pkgs; lib.mkDefault [
      # Popular wallpaper collections
      # Note: Individual wallpapers can be placed in shared/wallpapers/
    ];
    
    # GNOME wallpaper configuration
    # GNOME wallpapers are typically set via:
    # gsettings set org.gnome.desktop.background picture-uri "file:///path/to/wallpaper"
    # Or via the Settings app
    
    # Plasma wallpaper configuration
    # Plasma wallpapers are set via systemsettings or via home-manager
    # The shared/wallpapers/ directory can be used to store custom wallpapers
  };
}


{ config, pkgs, lib, ... }:

let
  # Check which desktop environment is enabled
  isGnome = (config.features.desktop.environment or "none") == "gnome";
  isPlasma = (config.features.desktop.environment or "none") == "plasma";
  sharedThemesPath = ../../../../shared/themes;
in
{
  config = lib.mkIf (isGnome || isPlasma) {
    # System-wide theme packages
    environment.systemPackages = with pkgs; lib.mkDefault [
      # Popular GTK themes
      adwaita-qt6  # Adwaita theme for Qt applications
      arc-theme
      papirus-icon-theme
      numix-icon-theme-circle
      
      # KDE/Plasma themes
      libsForQt5.qtstyleplugins
      libsForQt5.qt5ct
    ];
    
    # GNOME-specific theme configuration
    # Note: GNOME themes are typically managed via gsettings or dconf
    # Users can set themes via: gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark"
    
    # Plasma-specific theme configuration
    # Note: Plasma themes are managed via systemsettings or via home-manager
  };
}


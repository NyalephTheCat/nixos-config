{ config, pkgs, lib, ... }:

{
  # GTK theme configuration (works for both GNOME and Plasma with GTK apps)
  gtk = {
    enable = true;
    
    # GTK 3 theme
    theme = {
      name = "Arc-Dark";
      package = pkgs.arc-theme;
    };
    
    # Icon theme
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    
    # Cursor theme
    cursorTheme = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    
    # GTK 3/4 theme preferences
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };
  
  # Qt theme configuration (for Plasma and Qt applications)
  qt = {
    enable = true;
    platformTheme.name = "gtk3";  # Use GTK theme for Qt apps
    style = {
      name = "adwaita-dark";
      package = pkgs.adwaita-qt6;
    };
  };
  
  # Note: Desktop-specific theme settings (GNOME/Plasma) are managed via:
  # - GNOME: gsettings/dconf (can be set in dconf.settings)
  # - Plasma: systemsettings or via home-manager programs.plasma6
}


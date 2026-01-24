{ config, pkgs, lib, ... }:

let
  # Check if GNOME is the selected desktop environment
  isEnabled = (config.features.desktop.environment or "none") == "gnome";
in
{
  config = lib.mkIf isEnabled {
    # X11 windowing system
    services.xserver.enable = true;

    # GNOME Desktop Environment
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # Keyboard layout configuration
    services.xserver.xkb = {
      layout = lib.mkDefault "us";
      variant = lib.mkDefault "intl";
    };

    # Console keymap
    console.keyMap = lib.mkDefault "us-acentos";

    # Exclude some default GNOME applications if desired
    environment.gnome.excludePackages = with pkgs; [
      # gnome-tour
      # gnome-connections
      # epiphany  # GNOME Web browser
    ];
  };
}


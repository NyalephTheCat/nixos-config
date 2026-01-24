{ config, pkgs, lib, ... }:

let
  # Check if plasma is the selected desktop environment
  isEnabled = (config.features.desktop.environment or "none") == "plasma";
in
{
  config = lib.mkIf isEnabled {
    # X11 windowing system
    services.xserver.enable = true;

    # KDE Plasma 6 Desktop Environment
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;

    # Keyboard layout configuration
    services.xserver.xkb = {
      layout = lib.mkDefault "us";
      variant = lib.mkDefault "intl"; # International variant with accents
    };

    # Console keymap (for TTY, not X11)
    console.keyMap = lib.mkDefault "us-acentos";
  };
}


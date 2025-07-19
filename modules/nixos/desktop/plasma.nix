{ config, lib, pkgs, ... }:

with lib;

let cfg = config.modules.desktop.plasma;
in {
  options.modules.desktop.plasma = {
    enable = mkEnableOption "KDE Plasma desktop environment";
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
      displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
      desktopManager.plasma6.enable = true;
    };

    # Enable Wayland support
    programs.dconf.enable = true;

    # Plasma-specific packages
    environment.systemPackages = with pkgs; [
      libsForQt5.qt5.qtgraphicaleffects
      kdePackages.sddm-kcm
      kdePackages.kdeplasma-addons
      kdePackages.plasma-browser-integration
    ];

    # Better integration with GTK apps
    programs.kdeconnect.enable = true;

    # Enable KDE partition manager
    programs.partition-manager.enable = true;
  };
}

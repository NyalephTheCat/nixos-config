{ config, lib, pkgs, helpers, ... }:
with lib;
let
  cfg = config.modules.desktop.plasma;
  inherit (helpers) mkOptBool;
in {
  options.modules.desktop.plasma = {
    enable = mkEnableOption "KDE Plasma desktop environment";
    
    wayland = mkOptBool false "Enable Wayland session (experimental)";
    
    displayManager = {
      sddm = mkOptBool true "Use SDDM display manager";
      autoLogin = {
        enable = mkOptBool false "Enable automatic login";
        user = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "User to automatically log in";
        };
      };
    };
    
    applications = {
      core = mkOptBool true "Install core KDE applications (Konsole, Dolphin, Kate)";
      utilities = mkOptBool true "Install KDE utilities (Spectacle, Ark, KCalc, etc.)";
      pim = mkOptBool false "Install KDE PIM suite (Kontact, KMail, etc.)";
      development = mkOptBool false "Install KDE development tools (KDevelop, etc.)";
    };
    
    theme = {
      global = mkOption {
        type = types.nullOr types.str;
        default = null;
        example = "breeze-dark";
        description = "Global theme to use";
      };
      
      kvantum = mkOptBool false "Enable Kvantum theme engine";
    };
  };

  config = mkIf cfg.enable {
    services.xserver = {
      enable = true;
    };
    
    services.displayManager.sddm = mkIf cfg.displayManager.sddm {
      enable = true;
      wayland.enable = cfg.wayland;
      autoLogin = mkIf cfg.displayManager.autoLogin.enable {
        enable = true;
        user = cfg.displayManager.autoLogin.user;
      };
    };
    
    services.desktopManager.plasma6.enable = true;

    environment.systemPackages = with pkgs; 
      # Core applications
      (optionals cfg.applications.core [
        kdePackages.konsole     # Terminal emulator
        kdePackages.dolphin     # File manager
        kdePackages.kate        # Text editor
      ]) ++
      
      # Utilities
      (optionals cfg.applications.utilities [
        kdePackages.spectacle   # Screenshot tool
        kdePackages.ark         # Archive manager
        kdePackages.kcalc       # Calculator
        kdePackages.kcharselect # Character selector
        kdePackages.kcolorchooser # Color picker
        kdePackages.kruler      # Screen ruler
        kdePackages.okular      # PDF viewer
        kdePackages.gwenview    # Image viewer
        kdePackages.elisa       # Music player
        kdePackages.kdeconnect-kde # Phone integration
        kdePackages.partitionmanager # Disk partitioning
      ]) ++
      
      # PIM suite
      (optionals cfg.applications.pim [
        kdePackages.kontact
        kdePackages.kmail
        kdePackages.korganizer
        kdePackages.kaddressbook
        kdePackages.knotes
        kdePackages.akregator
      ]) ++
      
      # Development tools
      (optionals cfg.applications.development [
        kdePackages.kdevelop
        kdePackages.kompare
        kdePackages.kdebugsettings
      ]) ++
      
      # Theme support
      (optionals cfg.theme.kvantum [
        libsForQt5.qtstyleplugin-kvantum
        qt6Packages.qtstyleplugin-kvantum
      ]);

    # Enable browsers module by default with Plasma
    modules.desktop.browsers.enable = mkDefault true;
    
    # Plasma-specific services
    services.power-profiles-daemon.enable = true;
    
    # Better integration
    programs.kdeconnect.enable = true;
    
    # XDG portal for better app integration
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.kdePackages.xdg-desktop-portal-kde ];
    };
    
    # Enable KDE partition manager backend
    programs.partition-manager.enable = cfg.applications.utilities;
  };
}

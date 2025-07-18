{ config, lib, pkgs, helpers, ... }:
with lib;
let
  cfg = config.modules.gaming;
  inherit (helpers) mkOptBool;
in {
  options.modules.gaming = {
    enable = mkEnableOption "Gaming setup with Steam and related tools";
    
    steam = {
      enable = mkOptBool true "Enable Steam";
      remotePlay = mkOptBool true "Enable Steam Remote Play";
      dedicatedServer = mkOptBool false "Enable Steam Dedicated Server";
      gamescope = mkOptBool true "Enable Gamescope session";
    };
    
    platforms = {
      lutris = mkOptBool true "Enable Lutris";
      heroic = mkOptBool true "Enable Heroic Games Launcher";
      bottles = mkOptBool true "Enable Bottles";
    };
    
    tools = {
      mangohud = mkOptBool true "Enable MangoHud overlay";
      gamemode = mkOptBool true "Enable GameMode";
      obs = mkOptBool true "Enable OBS Studio";
    };
    
    emulators = {
      retroarch = mkOptBool true "Enable RetroArch";
    };
    
    controllers = {
      xbox = mkOptBool true "Enable Xbox controller support";
      nintendo = mkOptBool true "Enable Nintendo controller support";
    };
  };

  config = mkIf cfg.enable {
    # Enable Steam
    programs.steam = mkIf cfg.steam.enable {
      enable = true;
      remotePlay.openFirewall = cfg.steam.remotePlay;
      dedicatedServer.openFirewall = cfg.steam.dedicatedServer;
      gamescopeSession.enable = cfg.steam.gamescope;
    };

    # Enable GameMode for better gaming performance
    programs.gamemode.enable = cfg.tools.gamemode;

    # Gaming-related packages
    environment.systemPackages = with pkgs; 
      # Gaming platforms
      (optionals cfg.platforms.lutris [ lutris ]) ++
      (optionals cfg.platforms.heroic [ heroic ]) ++
      (optionals cfg.platforms.bottles [ bottles ]) ++
      
      # Game tools
      (optionals cfg.tools.mangohud [ mangohud ]) ++
      (optionals cfg.steam.enable [ 
        gamescope
        protonup-qt
      ]) ++
      
      # Emulators
      (optionals cfg.emulators.retroarch [ retroarch ]) ++
      
      # Gaming utilities
      (optionals cfg.tools.obs [ obs-studio ]) ++
      
      # Controllers
      (optionals (cfg.controllers.xbox || cfg.controllers.nintendo) [ antimicrox ]);

    # Enable 32-bit support for games
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # Gaming-specific kernel parameters
    boot.kernel.sysctl = {
      "vm.max_map_count" = 2147483642; # For some games
    };

    # Enable controller support
    hardware.xpadneo.enable = cfg.controllers.xbox;
    services.joycond.enable = cfg.controllers.nintendo;
  };
}

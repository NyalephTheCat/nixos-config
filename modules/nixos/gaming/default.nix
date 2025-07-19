{ config, lib, pkgs, ... }:

with lib;

let cfg = config.modules.gaming;
in {
  options.modules.gaming = {
    enable = mkEnableOption "gaming support";

    steam = {
      enable = mkEnableOption "Steam support";
      gamescope = mkEnableOption "Gamescope compositor";
    };

    gamemode = mkEnableOption "GameMode support";
    mangohud = mkEnableOption "MangoHud overlay";
  };

  config = mkIf cfg.enable {
    # Enable 32-bit support for games
    hardware.opengl = {
      enable = true;
      driSupport32Bit = true;

      extraPackages = with pkgs; [ vaapiVdpau libvdpau-va-gl ];
      extraPackages32 = with pkgs.pkgsi686Linux; [ vaapiVdpau libvdpau-va-gl ];
    };

    # Steam configuration
    programs.steam = mkIf cfg.steam.enable {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;

      # Enable Gamescope session if requested
      gamescopeSession.enable = cfg.steam.gamescope;
    };

    # GameMode for optimizations
    programs.gamemode = mkIf cfg.gamemode {
      enable = true;
      settings = {
        general = {
          renice = 10;
          inhibit_screensaver = 1;
        };

        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = "high";
          nv_powermizer_mode = 1;
        };
      };
    };

    # Gaming-related packages
    environment.systemPackages = with pkgs; [
      # Wine and Proton-related
      wine
      winetricks
      protontricks

      # Performance monitoring
      (mkIf cfg.mangohud mangohud)

      # Lutris for non-Steam games
      lutris

      # Vulkan tools
      vulkan-tools
      vulkan-loader
      vulkan-validation-layers

      # Additional tools
      bottles # Alternative Wine manager
      heroic # Epic/GOG launcher
    ];

    # Enable Xbox controller support
    hardware.xone.enable = true;

    # Kernel parameters for better gaming performance
    boot.kernel.sysctl = {
      "vm.max_map_count" = 2147483642; # Needed for some games
      "kernel.unprivileged_userns_clone" = 1; # Needed for some anti-cheat
    };
  };
}

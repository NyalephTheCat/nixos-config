{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.applications.steam;
in
{
  options.applications.steam = {
    enable = mkEnableOption "Steam";

    package = mkOption {
      type = types.package;
      default = pkgs.steam;
      defaultText = "pkgs.steam";
      description = "The Steam package to use.";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ pkgs.steam-run ];
      defaultText = "[ pkgs.steam-run ]";
      description = "Additional packages to install alongside Steam.";
    };

    remotePlay = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Steam Remote Play.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = "Open firewall ports for Remote Play.";
      };
    };

    dedicatedServer = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Steam dedicated server support.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = "Open firewall ports for dedicated servers.";
      };
    };

    games = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "List of games to install via Steam.";
      example = "[ pkgs.steamPackages.steam ]";
    };

    extraCompatPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional compatibility packages (e.g., Proton versions, Wine).";
      example = "[ pkgs.protonup-qt ]";
    };

    extraEnv = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Extra environment variables to set for Steam.";
      example = { "STEAM_EXTRA_COMPAT_TOOL_PATHS" = "/home/user/.steam/root/compatibilitytools.d"; };
    };

    extraLibraries = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Extra libraries to make available to Steam games.";
      example = "[ pkgs.libGL pkgs.vulkan-loader ]";
    };

    sessionStorePath = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Custom path for Steam session store (null = use default).";
      example = "/home/user/.steam/session";
    };

    performance = {
      gamemode = mkOption {
        type = types.bool;
        default = false;
        description = "Enable gamemode for better gaming performance.";
      };

      mangohud = mkOption {
        type = types.bool;
        default = false;
        description = "Enable MangoHud overlay for performance monitoring.";
      };
    };

    proton = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Proton compatibility layer support.";
      };

      versions = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "Proton versions to install (e.g., proton-ge, protonup-qt).";
        example = "[ pkgs.protonup-qt ]";
      };
    };

    controller = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Steam Controller support.";
      };

      xboxdrv = mkOption {
        type = types.bool;
        default = false;
        description = "Enable xboxdrv for Xbox controller support.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ] 
      ++ cfg.extraPackages
      ++ cfg.extraCompatPackages
      ++ cfg.extraLibraries
      ++ (lib.optional cfg.performance.gamemode pkgs.gamemode)
      ++ (lib.optional cfg.performance.mangohud pkgs.mangohud)
      ++ (lib.optional cfg.controller.xboxdrv pkgs.xboxdrv)
      ++ cfg.proton.versions;

    # Note: Steam configuration is done at the NixOS system level, not home-manager level
    # The programs.steam option is a NixOS option, not a home-manager option
    # If you need to configure Steam at the system level, add it to your host configuration
    # For now, we just install the packages

    # Set up environment variables for performance tools
    home.sessionVariables = mkMerge [
      (mkIf cfg.performance.gamemode {
        STEAM_COMPAT_CLIENT_INSTALL_PATH = "${pkgs.steam}/bin/steam";
      })
      (mkIf cfg.performance.mangohud {
        MANGOHUD = "1";
      })
    ];
  };
}


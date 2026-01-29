{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.system.basicApps;
in
{
  options.system.basicApps = {
    enable = mkEnableOption "basic system applications";

    fileManagement = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Install file management utilities.";
      };

      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [ file ];
        description = "File management packages.";
      };
    };

    textEditors = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Install text editors.";
      };

      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [ nano vim ];
        description = "Text editor packages.";
      };
    };

    systemUtilities = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Install system utilities.";
      };

      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [ htop neofetch git wget curl ];
        description = "System utility packages.";
      };
    };

    archiveTools = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Install archive tools.";
      };

      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [ unzip zip ];
        description = "Archive tool packages.";
      };
    };

    networkTools = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Install network tools.";
      };

      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [ networkmanagerapplet ];
        description = "Network tool packages.";
      };
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional system packages.";
    };
  };

  config = mkIf cfg.enable {
    # Essential system packages
    environment.systemPackages = 
      (if cfg.fileManagement.enable then cfg.fileManagement.packages else [])
      ++ (if cfg.textEditors.enable then cfg.textEditors.packages else [])
      ++ (if cfg.systemUtilities.enable then cfg.systemUtilities.packages else [])
      ++ (if cfg.archiveTools.enable then cfg.archiveTools.packages else [])
      ++ (if cfg.networkTools.enable then cfg.networkTools.packages else [])
      ++ cfg.extraPackages;

    # Enable network manager
    networking.networkmanager.enable = true;

    # Enable automatic system upgrades
    system.autoUpgrade = {
      enable = false; # Set to true if desired
      allowReboot = false;
    };
  };
}


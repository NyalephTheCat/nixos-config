{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.system.fonts;
in
{
  options.system.fonts = {
    enable = mkEnableOption "system font configuration";

    fonts = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        dejavu_fonts
        liberation_ttf
        noto-fonts
        noto-fonts-emoji
      ];
      description = "List of system font packages to install.";
    };

    fontconfig = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable fontconfig.";
      };

      antialias = mkOption {
        type = types.bool;
        default = true;
        description = "Enable font antialiasing.";
      };

      hinting = {
        enable = mkOption {
          type = types.bool;
          default = true;
          description = "Enable font hinting.";
        };

        style = mkOption {
          type = types.enum [ "none" "slight" "medium" "full" ];
          default = "slight";
          description = "Font hinting style.";
        };
      };

      subpixel = {
        lcdfilter = mkOption {
          type = types.enum [ "none" "default" "light" "legacy" ];
          default = "default";
          description = "LCD filter for subpixel rendering.";
        };

        rgba = mkOption {
          type = types.enum [ "none" "rgb" "bgr" "vrgb" "vbgr" ];
          default = "rgb";
          description = "Subpixel rendering order.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    fonts = {
      fonts = cfg.fonts;
      fontconfig = mkIf cfg.fontconfig.enable {
        enable = true;
        antialias = cfg.fontconfig.antialias;
        hinting = {
          enable = cfg.fontconfig.hinting.enable;
          style = cfg.fontconfig.hinting.style;
        };
        subpixel = {
          lcdfilter = cfg.fontconfig.subpixel.lcdfilter;
          rgba = cfg.fontconfig.subpixel.rgba;
        };
      };
    };
  };
}

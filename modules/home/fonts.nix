{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.home.fonts;
in
{
  options.home.fonts = {
    enable = mkEnableOption "font management";

    fonts = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "List of font packages to install.";
      example = "[ pkgs.dejavu_fonts pkgs.liberation_ttf ]";
    };

    nerdfonts = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Nerd Fonts.";
      };

      packages = mkOption {
        type = types.listOf types.str;
        default = [ "FiraCode" "Hack" "JetBrainsMono" ];
        description = "List of Nerd Font packages to install.";
        example = [ "FiraCode" "Hack" "SourceCodePro" ];
      };
    };

    systemFonts = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Install common system fonts.";
      };

      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          dejavu_fonts
          liberation_ttf
          noto-fonts
          noto-fonts-emoji
        ];
        description = "List of system font packages.";
      };
    };

    fontconfig = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable fontconfig configuration.";
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

      defaultFonts = {
        monospace = mkOption {
          type = types.listOf types.str;
          default = [ "FiraCode Nerd Font" "DejaVu Sans Mono" "Liberation Mono" ];
          description = "Default monospace fonts.";
        };

        sansSerif = mkOption {
          type = types.listOf types.str;
          default = [ "DejaVu Sans" "Liberation Sans" ];
          description = "Default sans-serif fonts.";
        };

        serif = mkOption {
          type = types.listOf types.str;
          default = [ "DejaVu Serif" "Liberation Serif" ];
          description = "Default serif fonts.";
        };
      };

      extraConfig = mkOption {
        type = types.lines;
        default = "";
        description = "Extra fontconfig configuration.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = cfg.fonts
      ++ (if cfg.systemFonts.enable then cfg.systemFonts.packages else [])
      ++ (if cfg.nerdfonts.enable then [
        (pkgs.nerdfonts.override { fonts = cfg.nerdfonts.packages; })
      ] else []);

    # Note: fonts.fontconfig options are managed by Home Manager automatically
    # Custom fontconfig settings can be added via fonts.fontconfig.localConf

    # Extra fontconfig configuration
    home.file.".config/fontconfig/conf.d/99-extra.conf" = mkIf (cfg.fontconfig.enable && cfg.fontconfig.extraConfig != "") {
      text = cfg.fontconfig.extraConfig;
    };
  };
}

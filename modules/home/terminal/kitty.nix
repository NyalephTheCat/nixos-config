{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.terminal.kitty;
in
{
  options.terminal.kitty = {
    enable = mkEnableOption "Kitty terminal";

    package = mkOption {
      type = types.package;
      default = pkgs.kitty;
      defaultText = "pkgs.kitty";
      description = "The Kitty package to use.";
    };

    font = {
      family = mkOption {
        type = types.str;
        default = "FiraCode Nerd Font";
        description = "Font family for Kitty.";
      };

      size = mkOption {
        type = types.number;
        default = 12;
        description = "Font size in points.";
      };
    };

    theme = {
      foreground = mkOption {
        type = types.str;
        default = "#CDD6F4";
        description = "Foreground color.";
      };

      background = mkOption {
        type = types.str;
        default = "#1E1E2E";
        description = "Background color.";
      };

      selectionForeground = mkOption {
        type = types.str;
        default = "#1E1E2E";
        description = "Selection foreground color.";
      };

      selectionBackground = mkOption {
        type = types.str;
        default = "#F5E0DC";
        description = "Selection background color.";
      };
    };

    window = {
      opacity = mkOption {
        type = types.str;
        default = "0.95";
        description = "Window background opacity (0.0 to 1.0).";
      };

      padding = {
        x = mkOption {
          type = types.int;
          default = 0;
          description = "Horizontal padding in pixels.";
        };

        y = mkOption {
          type = types.int;
          default = 0;
          description = "Vertical padding in pixels.";
        };
      };
    };

    audioBell = mkOption {
      type = types.bool;
      default = false;
      description = "Enable audio bell.";
    };

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional Kitty settings (merged with defaults).";
    };

    keybindings = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Custom keybindings.";
      example = { "ctrl+shift+c" = "copy_to_clipboard"; };
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra Kitty configuration.";
    };
  };

  config = mkIf cfg.enable {
    # Install Fira Code Nerd Font
    home.packages = with pkgs; lib.optional (pkgs ? nerdfonts) [
      (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
    ];

    programs.kitty = {
      enable = true;
      package = cfg.package;
      settings = {
        foreground = cfg.theme.foreground;
        background = cfg.theme.background;
        selection_foreground = cfg.theme.selectionForeground;
        selection_background = cfg.theme.selectionBackground;
        font_family = cfg.font.family;
        font_size = cfg.font.size;
        background_opacity = cfg.window.opacity;
        enable_audio_bell = cfg.audioBell;
        window_padding_width = "${toString cfg.window.padding.x} ${toString cfg.window.padding.y}";
      } // cfg.settings // cfg.keybindings;
      extraConfig = cfg.extraConfig;
    };
  };
}


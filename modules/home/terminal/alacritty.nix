{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.terminal.alacritty;
in
{
  options.terminal.alacritty = {
    enable = mkEnableOption "Alacritty terminal";

    package = mkOption {
      type = types.package;
      default = pkgs.alacritty;
      defaultText = "pkgs.alacritty";
      description = "The Alacritty package to use.";
    };

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Alacritty configuration settings.";
    };

    theme = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Alacritty theme to use (e.g., 'catppuccin-mocha', 'dracula').";
    };

    font = {
      size = mkOption {
        type = types.number;
        default = 12.0;
        description = "Font size in points.";
      };

      normal = {
        family = mkOption {
          type = types.str;
          default = "FiraCode Nerd Font";
          description = "Normal font family.";
        };

        style = mkOption {
          type = types.str;
          default = "Regular";
          description = "Normal font style.";
        };
      };

      bold = {
        family = mkOption {
          type = types.str;
          default = "FiraCode Nerd Font";
          description = "Bold font family.";
        };

        style = mkOption {
          type = types.str;
          default = "Bold";
          description = "Bold font style.";
        };
      };

      italic = {
        family = mkOption {
          type = types.str;
          default = "FiraCode Nerd Font";
          description = "Italic font family.";
        };

        style = mkOption {
          type = types.str;
          default = "Italic";
          description = "Italic font style.";
        };
      };
    };

    colors = mkOption {
      type = types.nullOr types.attrs;
      default = null;
      description = "Custom color scheme (overrides theme if set).";
    };

    window = {
      opacity = mkOption {
        type = types.number;
        default = 1.0;
        description = "Window opacity (0.0 to 1.0).";
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

      decorations = mkOption {
        type = types.enum [ "Full" "None" "Transparent" "Buttonless" ];
        default = "Full";
        description = "Window decorations style.";
      };
    };

    scrolling = {
      history = mkOption {
        type = types.int;
        default = 10000;
        description = "Maximum number of lines in scrollback buffer.";
      };

      multiplier = mkOption {
        type = types.int;
        default = 3;
        description = "Number of line scrolled per mouse wheel click.";
      };
    };

    keybindings = mkOption {
      type = types.listOf types.attrs;
      default = [];
      description = "Custom keybindings.";
      example = [
        {
          key = "V";
          mods = "Control|Shift";
          action = "Paste";
        }
      ];
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra Alacritty configuration (YAML format).";
    };
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      package = cfg.package;
      settings = cfg.settings // {
        font = {
          size = cfg.font.size;
          normal = cfg.font.normal;
          bold = cfg.font.bold;
          italic = cfg.font.italic;
        };
        window = {
          opacity = cfg.window.opacity;
          padding = {
            x = cfg.window.padding.x;
            y = cfg.window.padding.y;
          };
          decorations = cfg.window.decorations;
        };
        scrolling = {
          history = cfg.scrolling.history;
          multiplier = cfg.scrolling.multiplier;
        };
        key_bindings = cfg.keybindings;
      } // (if cfg.colors != null then { colors = cfg.colors; } else {})
        // (if cfg.theme != null then { import = [ "~/.config/alacritty/themes/${cfg.theme}.toml" ]; } else {});
    };

    # Note: Themes can be installed via home.packages or configured manually
    # Example: home.packages = [ pkgs.alacritty-themes ];
  };
}

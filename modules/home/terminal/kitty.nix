{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.terminal.kitty;
in
{
  options.terminal.kitty = {
    enable = mkEnableOption "Kitty terminal";
  };

  config = mkIf cfg.enable {
    # Install Fira Code Nerd Font
    home.packages = with pkgs; lib.optional (pkgs ? nerdfonts) [
      (pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; })
    ];

    programs.kitty = {
      enable = true;
      # theme is deprecated, use themeFile or configure via settings
      settings = {
        # Theme can be set via color scheme in settings
        foreground = "#CDD6F4";
        background = "#1E1E2E";
        selection_foreground = "#1E1E2E";
        selection_background = "#F5E0DC";
        font_family = "FiraCode Nerd Font";
        font_size = 12;
        background_opacity = "0.95";
        enable_audio_bell = false;
      };
    };
  };
}


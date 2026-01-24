{ config, pkgs, lib, ... }:

{
  # Kitty terminal configuration
  programs.kitty = {
    enable = lib.mkDefault false; # Disabled by default, enable in user config
    settings = {
      font_family = lib.mkDefault "FiraCode Nerd Font";
      font_size = lib.mkDefault 12;
      background_opacity = lib.mkDefault "0.95";
      enable_audio_bell = lib.mkDefault false;
      window_padding_width = lib.mkDefault 5;
      confirm_os_window_close = lib.mkDefault 0;
    };
  };

  # Alacritty terminal configuration
  programs.alacritty = {
    enable = lib.mkDefault false; # Disabled by default, enable in user config
    settings = {
      font = {
        normal = {
          family = lib.mkDefault "FiraCode Nerd Font";
          style = lib.mkDefault "Regular";
        };
        size = lib.mkDefault 12;
      };
      window = {
        opacity = lib.mkDefault 0.95;
        padding = {
          x = lib.mkDefault 5;
          y = lib.mkDefault 5;
        };
      };
    };
  };
}


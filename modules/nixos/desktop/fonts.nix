{ config, lib, pkgs, ... }:

with lib;

let cfg = config.modules.desktop.fonts;
in {
  options.modules.desktop.fonts = { enable = mkEnableOption "custom fonts"; };

  config = mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        liberation_ttf
        jetbrains-mono
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
      ];

      fontconfig = {
        defaultFonts = {
          serif = [ "Noto Serif" ];
          sansSerif = [ "Noto Sans" ];
          monospace = [ "JetBrains Mono" ];
          emoji = [ "Noto Color Emoji" ];
        };
      };
    };
  };
}

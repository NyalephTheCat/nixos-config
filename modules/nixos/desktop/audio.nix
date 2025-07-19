{ config, lib, pkgs, ... }:

with lib;

let cfg = config.modules.desktop.audio;
in {
  options.modules.desktop.audio = { enable = mkEnableOption "audio support"; };

  config = mkIf cfg.enable {
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };

    environment.systemPackages = with pkgs; [ pavucontrol pamixer easyeffects ];
  };
}

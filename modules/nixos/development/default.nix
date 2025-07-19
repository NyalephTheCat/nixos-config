{ config, lib, pkgs, ... }:

with lib;

let cfg = config.modules.development;
in {
  options.modules.development = {
    enable = mkEnableOption "development tools";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      gcc
      gnumake
      python3
      nodejs
      rustup
      go
    ];
  };
}

{ config, pkgs, lib, customUtils, ... }:

(customUtils.mkMultipleApps [
  { name = "discord"; defaultPackage = pkgs.discord; description = "Discord"; packageExample = "pkgs.discord-ptb"; }
  { name = "vesktop"; defaultPackage = pkgs.vesktop; description = "Vesktop"; }
  { name = "zapzap"; defaultPackage = pkgs.zapzap; description = "ZapZap"; }
]) { inherit config pkgs lib; }


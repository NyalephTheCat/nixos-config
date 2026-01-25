{ config, pkgs, lib, customUtils, ... }:

(customUtils.mkMultipleApps [
  { name = "krita"; defaultPackage = pkgs.krita; description = "Krita"; }
  { name = "audacity"; defaultPackage = pkgs.audacity; description = "Audacity"; }
  { name = "vlc"; defaultPackage = pkgs.vlc; description = "VLC"; }
]) { inherit config pkgs lib; }


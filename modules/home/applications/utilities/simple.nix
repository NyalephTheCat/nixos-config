{ config, pkgs, lib, customUtils, ... }:

(customUtils.mkMultipleApps [
  { name = "qbittorrent"; defaultPackage = pkgs.qbittorrent; description = "qBittorrent"; packageExample = "pkgs.qbittorrent-nox"; }
]) { inherit config pkgs lib; }


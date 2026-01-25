{ config, pkgs, lib, customUtils, ... }:

(customUtils.mkMultipleApps [
  { name = "obsidian"; defaultPackage = pkgs.obsidian; description = "Obsidian"; }
  { name = "libreoffice"; defaultPackage = pkgs.libreoffice; description = "LibreOffice"; packageExample = "pkgs.libreoffice-fresh"; }
]) { inherit config pkgs lib; }


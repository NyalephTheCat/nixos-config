{ config, pkgs, lib, customUtils, ... }:

# System monitoring and disk utilities
(customUtils.mkMultipleApps [
  { name = "htop"; defaultPackage = pkgs.htop; description = "Htop process monitor"; }
  { name = "btop"; defaultPackage = pkgs.btop; description = "Btop system monitor"; }
  { name = "ncdu"; defaultPackage = pkgs.ncdu; description = "NCurses disk usage analyzer"; }
  { name = "duf"; defaultPackage = pkgs.duf; description = "Disk usage/free utility"; }
  { name = "dust"; defaultPackage = pkgs.dust; description = "Dust disk usage analyzer"; }
  { name = "procs"; defaultPackage = pkgs.procs; description = "Modern process viewer"; }
  { name = "bottom"; defaultPackage = pkgs.bottom; description = "Bottom system monitor"; }
]) { inherit config pkgs lib; }

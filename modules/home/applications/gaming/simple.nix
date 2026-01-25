{ config, pkgs, lib, customUtils, ... }:

(customUtils.mkMultipleApps [
  { name = "lutris"; defaultPackage = pkgs.lutris; description = "Lutris"; }
  { name = "r2modman"; defaultPackage = pkgs.r2modman; description = "r2modman"; }
]) { inherit config pkgs lib; }


{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.applications.cursor;
in
{
  options.applications.cursor = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Cursor IDE.";
    };

    package = mkOption {
      type = types.nullOr types.package;
      default = pkgs.code-cursor;
      description = "The Cursor IDE package to use. If null, cursor will not be installed.";
      example = "pkgs.cursor";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages to install alongside Cursor IDE.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = 
      (if cfg.package != null then [ cfg.package ] else [])
      ++ cfg.extraPackages;
  };
}


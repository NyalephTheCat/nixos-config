{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.system.printing;
in
{
  options.system.printing = {
    enable = mkEnableOption "CUPS printing service";

    drivers = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [ gutenprint cups-filters ];
      description = "List of printer driver packages.";
    };

    browsable = mkOption {
      type = types.bool;
      default = true;
      description = "Make printers browsable on the network.";
    };

    defaultShared = mkOption {
      type = types.bool;
      default = false;
      description = "Share printers by default.";
    };
  };

  config = mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = cfg.drivers;
      browsing = cfg.browsable;
      defaultShared = cfg.defaultShared;
    };
  };
}

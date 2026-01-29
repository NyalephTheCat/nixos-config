{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.system.customServices;
in
{
  options.system.customServices = {
    printing = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable CUPS printing service.";
      };

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

    avahi = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Avahi (mDNS/DNS-SD) service.";
      };

      nssmdns = mkOption {
        type = types.bool;
        default = true;
        description = "Enable mDNS name resolution.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = "Open firewall ports for Avahi.";
      };
    };

  };

  config = {
    # CUPS printing
    services.printing = mkIf cfg.printing.enable {
      enable = true;
      drivers = cfg.printing.drivers;
      browsing = cfg.printing.browsable;
      defaultShared = cfg.printing.defaultShared;
    };

    # Avahi
    services.avahi = mkIf cfg.avahi.enable {
      enable = true;
      nssmdns = cfg.avahi.nssmdns;
      openFirewall = cfg.avahi.openFirewall;
    };
  };
}

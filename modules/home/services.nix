{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.services;
in
{
  options.services = {
    enable = mkEnableOption "user-level systemd services";

    # Note: syncthing is already provided by Home Manager's services.syncthing
    # Configure it directly using Home Manager's built-in options

    custom = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          Unit = mkOption {
            type = types.attrs;
            default = {};
            description = "Systemd unit section.";
          };
          Service = mkOption {
            type = types.attrs;
            default = {};
            description = "Systemd service section.";
          };
          Install = mkOption {
            type = types.attrs;
            default = {};
            description = "Systemd install section.";
          };
        };
      });
      default = {};
      description = "Custom user systemd services.";
    };
  };

  config = mkIf cfg.enable {
    # Custom user services
    systemd.user.services = lib.mapAttrs' (name: service: {
      name = name;
      value = {
        Unit = service.Unit;
        Service = service.Service;
        Install = service.Install;
      };
    }) cfg.custom;
  };
}

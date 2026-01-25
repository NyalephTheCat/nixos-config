{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.applications.thunderbird;
in
{
  options.applications.thunderbird = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Thunderbird.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.thunderbird;
      defaultText = "pkgs.thunderbird";
      description = "The Thunderbird package to use.";
    };

    profiles = mkOption {
      type = types.attrsOf (types.submodule {
        options = {
          isDefault = mkOption {
            type = types.bool;
            default = false;
            description = "Whether this profile is the default.";
          };
        };
      });
      default = {};
      description = "Thunderbird profiles configuration.";
    };

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Thunderbird preferences to set.";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages to install alongside Thunderbird.";
    };
  };

  config = mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;
      package = cfg.package;
      profiles = cfg.profiles;
      settings = cfg.settings;
    };

    home.packages = cfg.extraPackages;
  };
}


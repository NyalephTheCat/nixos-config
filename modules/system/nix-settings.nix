{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.system.nix;
in
{
  options.system.nix = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable Nix-specific settings (flakes, gc, etc.).";
    };

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Additional Nix settings (nix.settings). Flakes and nix-command are always enabled for all users.";
    };

    gc = {
      automatic = mkOption {
        type = types.bool;
        default = true;
        description = "Enable automatic garbage collection.";
      };

      dates = mkOption {
        type = types.str;
        default = "weekly";
        description = "Garbage collection schedule (systemd timer format).";
      };

      options = mkOption {
        type = types.str;
        default = "--delete-older-than 30d";
        description = "Garbage collection options.";
      };
    };

    optimise = {
      automatic = mkOption {
        type = types.bool;
        default = false;
        description = "Enable automatic store optimisation.";
      };

      dates = mkOption {
        type = types.str;
        default = "weekly";
        description = "Store optimisation schedule.";
      };
    };

    trustedUsers = mkOption {
      type = types.listOf types.str;
      default = [ "root" ];
      description = "List of trusted users for Nix operations.";
    };

    trustedPublicKeys = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of trusted public keys for binary caches.";
    };

    substituters = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of binary cache substituters.";
      example = [ "https://cache.nixos.org" ];
    };

    extraOptions = mkOption {
      type = types.lines;
      default = "";
      description = "Extra Nix configuration options.";
    };
  };

  config = mkIf cfg.enable {
    nix.settings = {
      experimental-features = [ "nix-command" "flakes" ];
    } // cfg.settings // (lib.optionalAttrs (cfg.trustedUsers != []) {
      trusted-users = cfg.trustedUsers;
    }) // (lib.optionalAttrs (cfg.trustedPublicKeys != []) {
      trusted-public-keys = cfg.trustedPublicKeys;
    }) // (lib.optionalAttrs (cfg.substituters != []) {
      substituters = cfg.substituters;
    });

    nix.extraOptions = cfg.extraOptions;

    nix.gc = {
      automatic = cfg.gc.automatic;
      dates = cfg.gc.dates;
      options = cfg.gc.options;
    };

    nix.optimise = {
      automatic = cfg.optimise.automatic;
      dates = cfg.optimise.dates;
    };
  };
}

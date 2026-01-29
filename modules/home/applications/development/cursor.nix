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

    settings = mkOption {
      type = types.attrs;
      default = {};
      description = "Cursor IDE settings (settings.json).";
    };

    keybindings = mkOption {
      type = types.attrs;
      default = {};
      description = "Cursor IDE keybindings (keybindings.json).";
    };

    extensions = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "List of Cursor extension IDs to install.";
      example = [ "ms-python.python" "rust-lang.rust-analyzer" ];
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra Cursor configuration (will be written to settings.json).";
    };
  };

  config = mkIf cfg.enable {
    home.packages = 
      (if cfg.package != null then [ cfg.package ] else [])
      ++ cfg.extraPackages;

    # Cursor settings
    home.file.".config/Cursor/User/settings.json" = mkIf (cfg.settings != {} || cfg.extraConfig != "") {
      text = builtins.toJSON (cfg.settings // (if cfg.extraConfig != "" then { _extra = cfg.extraConfig; } else {}));
    };

    # Cursor keybindings
    home.file.".config/Cursor/User/keybindings.json" = mkIf (cfg.keybindings != {}) {
      text = builtins.toJSON cfg.keybindings;
    };
  };
}


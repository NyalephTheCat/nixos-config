{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.applications.vscode;
in
{
  options.applications.vscode = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable VS Code.";
    };

    package = mkOption {
      type = types.package;
      default = pkgs.vscode;
      defaultText = "pkgs.vscode";
      description = "The VS Code package to use.";
      example = "pkgs.vscode-fhs";
    };

    extensions = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "List of VS Code extensions to install.";
      example = "[ pkgs.vscode-extensions.ms-python.python ]";
    };

    userSettings = mkOption {
      type = types.attrs;
      default = {};
      description = "VS Code user settings.";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages to install alongside VS Code.";
    };
  };

  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = cfg.package;
      profiles.default = {
        extensions = cfg.extensions;
        userSettings = cfg.userSettings;
      };
    };

    home.packages = cfg.extraPackages;
  };
}


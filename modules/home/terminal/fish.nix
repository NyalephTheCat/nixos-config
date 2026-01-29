{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.terminal.fish;
in
{
  options.terminal.fish = {
    enable = mkEnableOption "Fish shell";

    package = mkOption {
      type = types.package;
      default = pkgs.fish;
      defaultText = "pkgs.fish";
      description = "The Fish shell package to use.";
    };

    shellInit = mkOption {
      type = types.lines;
      default = "";
      description = "Fish shell initialization code.";
    };

    shellAbbrs = mkOption {
      type = types.attrsOf types.str;
      default = {
        ll = "ls -l";
        la = "ls -la";
        l = "ls -lah";
        ".." = "cd ..";
        "..." = "cd ../..";
        grep = "grep --color=auto";
      };
      description = "Fish shell abbreviations.";
    };

    shellAliases = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Fish shell aliases.";
    };

    functions = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Fish shell functions.";
    };

    interactiveShellInit = mkOption {
      type = types.lines;
      default = "";
      description = "Fish interactive shell initialization code.";
    };

    loginShellInit = mkOption {
      type = types.lines;
      default = "";
      description = "Fish login shell initialization code.";
    };

    plugins = mkOption {
      type = types.listOf (types.either types.package types.str);
      default = [];
      description = "List of Fish plugins to install.";
      example = [ "done" "fzf" ];
    };

    promptInit = mkOption {
      type = types.lines;
      default = "";
      description = "Fish prompt initialization code.";
    };
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      package = cfg.package;
      shellInit = cfg.shellInit;
      shellAbbrs = cfg.shellAbbrs;
      shellAliases = cfg.shellAliases;
      functions = cfg.functions;
      interactiveShellInit = cfg.interactiveShellInit;
      loginShellInit = cfg.loginShellInit;
      plugins = cfg.plugins;
      promptInit = cfg.promptInit;
    };
  };
}

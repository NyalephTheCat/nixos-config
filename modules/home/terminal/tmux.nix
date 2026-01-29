{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.terminal.tmux;
in
{
  options.terminal.tmux = {
    enable = mkEnableOption "Tmux terminal multiplexer";

    package = mkOption {
      type = types.package;
      default = pkgs.tmux;
      defaultText = "pkgs.tmux";
      description = "The Tmux package to use.";
    };

    prefix = mkOption {
      type = types.str;
      default = "C-b";
      description = "Prefix key combination.";
    };

    baseIndex = mkOption {
      type = types.int;
      default = 1;
      description = "Base index for windows and panes (0 or 1).";
    };

    escapeTime = mkOption {
      type = types.int;
      default = 0;
      description = "Escape time in milliseconds.";
    };

    historyLimit = mkOption {
      type = types.int;
      default = 10000;
      description = "Maximum number of lines in history.";
    };

    mouse = mkOption {
      type = types.bool;
      default = true;
      description = "Enable mouse support.";
    };

    clock24 = mkOption {
      type = types.bool;
      default = true;
      description = "Use 24-hour clock format.";
    };

    plugins = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        tmuxPlugins.sensible
        tmuxPlugins.resurrect
        tmuxPlugins.continuum
      ];
      description = "List of Tmux plugins to install.";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = "Extra Tmux configuration.";
    };

    keyMode = mkOption {
      type = types.enum [ "vi" "emacs" ];
      default = "vi";
      description = "Key binding mode.";
    };

    terminal = mkOption {
      type = types.str;
      default = "screen-256color";
      description = "Terminal type.";
    };

    newSession = mkOption {
      type = types.bool;
      default = false;
      description = "Start new session if no session exists.";
    };

    aggressiveResize = mkOption {
      type = types.bool;
      default = false;
      description = "Aggressively resize windows.";
    };
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      package = cfg.package;
      prefix = cfg.prefix;
      baseIndex = cfg.baseIndex;
      escapeTime = cfg.escapeTime;
      historyLimit = cfg.historyLimit;
      mouse = cfg.mouse;
      clock24 = cfg.clock24;
      plugins = cfg.plugins;
      extraConfig = cfg.extraConfig;
      keyMode = cfg.keyMode;
      terminal = cfg.terminal;
      newSession = cfg.newSession;
      aggressiveResize = cfg.aggressiveResize;
      # Note: customPaneNavigationBindings and disableSensible are not available
      # in Home Manager's programs.tmux - configure via extraConfig if needed
    };
  };
}

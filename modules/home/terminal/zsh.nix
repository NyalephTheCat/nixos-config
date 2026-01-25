{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.terminal.zsh;
in
{
  options.terminal.zsh = {
    enable = mkEnableOption "Zsh";

    # History configuration
    history = {
      size = mkOption {
        type = types.int;
        default = 10000;
        description = "Maximum number of history entries to keep in memory.";
      };

      save = mkOption {
        type = types.int;
        default = 10000;
        description = "Maximum number of history entries to save to disk.";
      };

      path = mkOption {
        type = types.str;
        default = "${config.xdg.dataHome}/zsh/history";
        description = "Path to the zsh history file.";
      };

      ignoreDups = mkOption {
        type = types.bool;
        default = true;
        description = "Ignore duplicate commands in history.";
      };

      ignoreSpace = mkOption {
        type = types.bool;
        default = true;
        description = "Ignore commands that start with a space.";
      };

      share = mkOption {
        type = types.bool;
        default = true;
        description = "Share history between all sessions.";
      };
    };

    # Completion configuration
    completion = {
      caseInsensitive = mkOption {
        type = types.bool;
        default = true;
        description = "Enable case-insensitive completion.";
      };

      caseGlob = mkOption {
        type = types.bool;
        default = true;
        description = "Enable case-insensitive globbing.";
      };

      matcherList = mkOption {
        type = types.listOf types.str;
        default = [ "m:{a-zA-Z}={A-Za-z}" "r:|[._-]=* r:|=*" "l:|=* r:|=*" ];
        description = "List of completion matchers for better matching.";
      };
    };

    # Autosuggestions configuration
    autosuggestions = {
      strategy = mkOption {
        type = types.enum [ "history" "completion" "match_prev_cmd" ];
        default = "history";
        description = "Autosuggestion strategy.";
      };

      highlightStyle = mkOption {
        type = types.str;
        default = "fg=8";
        description = "Highlight style for autosuggestions (zsh-syntax-highlighting format).";
      };
    };

    # Syntax highlighting configuration
    syntaxHighlighting = {
      highlighters = mkOption {
        type = types.listOf types.str;
        default = [
          "main"
          "brackets"
          "pattern"
          "regexp"
          "root"
          "line"
        ];
        description = "List of syntax highlighters to enable.";
      };

      patterns = mkOption {
        type = types.attrsOf types.str;
        default = {};
        description = "Custom syntax highlighting patterns.";
        example = { "rm -rf *" = "fg=red,bold"; };
      };
    };

    # Oh-My-Zsh configuration
    ohMyZsh = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Oh-My-Zsh framework.";
      };

      plugins = mkOption {
        type = types.listOf (types.either types.str types.attrs);
        default = [
          "git"
          "docker"
          "kubectl"
          "sudo"
          "colored-man-pages"
          "colorize"
          "command-not-found"
          "extract"
          "history"
          "z"
        ];
        description = "List of Oh-My-Zsh plugins to enable.";
      };

      theme = mkOption {
        type = types.nullOr types.str;
        default = "robbyrussell";
        description = "Oh-My-Zsh theme to use. Set to null to use starship or custom prompt.";
      };

      custom = mkOption {
        type = types.str;
        default = "";
        description = "Path to custom Oh-My-Zsh directory (for custom themes/plugins).";
      };
    };

    # Starship prompt configuration
    starship = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Starship prompt (overrides oh-my-zsh theme if enabled).";
      };

      settings = mkOption {
        type = types.attrs;
        default = {
          add_newline = true;
          format = "$all$character";
          character = {
            success_symbol = "[➜](bold green)";
            error_symbol = "[➜](bold red)";
          };
          git_branch = {
            symbol = " ";
            style = "bold purple";
          };
          git_status = {
            conflicted = "⚡";
            up_to_date = "";
            untracked = "?";
            ahead = "⇡";
            behind = "⇣";
            diverged = "⇕";
            stashed = "$";
            modified = "!";
            staged = "+";
            renamed = "»";
            deleted = "✘";
          };
          directory = {
            truncation_length = 3;
            truncate_to_repo = true;
            style = "bold cyan";
          };
          cmd_duration = {
            min_time = 2;
            format = "took [$duration](bold yellow)";
          };
          python = {
            symbol = " ";
            style = "bold yellow";
          };
          nodejs = {
            symbol = " ";
            style = "bold green";
          };
          rust = {
            symbol = " ";
            style = "bold red";
          };
        };
        description = "Starship prompt configuration.";
      };

      configPath = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Path to starship config file. If null, uses settings option.";
      };
    };

    # Shell aliases
    shellAliases = mkOption {
      type = types.attrsOf types.str;
      default = {
        ll = "ls -l";
        la = "ls -la";
        l = "ls -lah";
        ".." = "cd ..";
        "..." = "cd ../..";
        "...." = "cd ../../..";
        grep = "grep --color=auto";
        fgrep = "fgrep --color=auto";
        egrep = "egrep --color=auto";
        diff = "diff --color=auto";
        ip = "ip --color=auto";
      };
      description = "Shell aliases to set.";
    };

    # Environment variables
    envExtra = mkOption {
      type = types.str;
      default = "";
      description = "Extra environment variables to set in zsh.";
    };

    # Init extra (custom zsh code)
    initContent = mkOption {
      type = types.str;
      default = "";
      description = "Extra zsh initialization code.";
    };

    # Init extra before compinit
    initExtraBeforeCompInit = mkOption {
      type = types.str;
      default = "";
      description = "Extra zsh initialization code before compinit.";
    };

    # Profile extra
    profileExtra = mkOption {
      type = types.str;
      default = "";
      description = "Extra code to add to zprofile.";
    };

    # Extra packages
    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages to install for zsh.";
    };
  };

  config = mkIf cfg.enable {
    # Install starship if enabled
    programs.starship = mkIf cfg.starship.enable {
      enable = true;
      settings = cfg.starship.settings;
    } // (if cfg.starship.configPath != null then {
      configFile = cfg.starship.configPath;
    } else {});

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      
      # History configuration
      history = {
        size = cfg.history.size;
        save = cfg.history.save;
        path = cfg.history.path;
        ignoreDups = cfg.history.ignoreDups;
        ignoreSpace = cfg.history.ignoreSpace;
        share = cfg.history.share;
      };

      # Completion options
      completionInit = ''
        # Completion matchers
        zstyle ':completion:*' matcher-list ${concatStringsSep " " (map (x: "'${x}'") cfg.completion.matcherList)}
        zstyle ':completion:*' menu select
        zstyle ':completion:*' list-colors ''${(s.:.)LS_COLORS}
        zstyle ':completion:*' special-dirs true
        zstyle ':completion:*' rehash true
      '' + (optionalString cfg.completion.caseInsensitive ''
        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      '') + (optionalString cfg.completion.caseGlob ''
        setopt CASE_GLOB
      '');

      # Syntax highlighting
      syntaxHighlighting = {
        enable = true;
        highlighters = cfg.syntaxHighlighting.highlighters;
        patterns = cfg.syntaxHighlighting.patterns;
      };

      # Oh-My-Zsh configuration
      oh-my-zsh = mkIf cfg.ohMyZsh.enable {
        enable = true;
        plugins = cfg.ohMyZsh.plugins;
        theme = if cfg.starship.enable then null else cfg.ohMyZsh.theme;
        custom = if cfg.ohMyZsh.custom != "" then cfg.ohMyZsh.custom else "";
      };

      # Shell aliases
      shellAliases = cfg.shellAliases;

      # Environment variables
      envExtra = cfg.envExtra;

      # Init content (initExtra is deprecated)
      initContent = ''
        # Enable colors
        export CLICOLOR=1
        export LSCOLORS=GxFxCxDxBxegedabagaced

        # Preferred editor
        ${if config.programs.neovim.enable or false then "export EDITOR=nvim" else "export EDITOR=vim"}

        # Custom prompt if starship is not enabled
        ${optionalString (!cfg.starship.enable && cfg.ohMyZsh.theme == null) ''
          # Custom prompt fallback
          PROMPT='%F{cyan}%n@%m%f %F{blue}%~%f %# '
        ''}

        # Autosuggestions configuration (if using zsh-autosuggestions plugin)
        ${optionalString (cfg.autosuggestions.strategy != null) ''
          ZSH_AUTOSUGGEST_STRATEGY=${cfg.autosuggestions.strategy}
        ''}
        ${optionalString (cfg.autosuggestions.highlightStyle != null) ''
          ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="${cfg.autosuggestions.highlightStyle}"
        ''}

        ${cfg.initContent}
      '';

      initExtraBeforeCompInit = cfg.initExtraBeforeCompInit;

      profileExtra = cfg.profileExtra;
    };

    # Install extra packages
    home.packages = cfg.extraPackages;
  };
}


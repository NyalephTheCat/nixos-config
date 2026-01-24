{ config, pkgs, lib, ... }:

{
  # Starship prompt
  programs.starship = {
    enable = lib.mkDefault true;
    enableZshIntegration = lib.mkDefault true;
    settings = {
      add_newline = lib.mkDefault true;
      format = lib.mkDefault "$directory$git_branch$git_status$nix_shell$nodejs$python$rust$cmd_duration$line_break$jobs$time$character";
      
      character = {
        success_symbol = lib.mkDefault "[➜](bold green)";
        error_symbol = lib.mkDefault "[✗](bold red)";
      };
      
      directory = {
        style = "bold cyan";
        truncation_length = 2;
        truncation_symbol = "…/";
      };
      
      git_branch = {
        style = "bold purple";
        truncation_length = 20;
      };
      
      git_status = {
        style = "bold red";
        format = "([\\[$all_status$ahead_behind\\]]($style))";
      };
      
      nix_shell = {
        format = "via [$symbol$state( \($name\))]($style) ";
        style = "bold blue";
      };
      
      cmd_duration = {
        min_time = 2000;
        style = "bold yellow";
      };
      
      jobs = {
        format = "[$symbol$number]($style) ";
        style = "bold blue";
        number_threshold = 1;
      };
      
      time = {
        time_format = "%H:%M:%S";
        style = "dimmed white";
        format = "[$time]($style) ";
      };
    };
  };

  # Direnv
  programs.direnv = {
    enable = lib.mkDefault true;
    enableZshIntegration = lib.mkDefault true;
    nix-direnv.enable = lib.mkDefault true;
  };

  # Zsh
  programs.zsh = {
    enable = lib.mkDefault true;
    enableCompletion = lib.mkDefault true;
    autosuggestion.enable = lib.mkDefault true;
    syntaxHighlighting.enable = lib.mkDefault true;
    
    # Use XDG config directory (modern behavior) to silence warning and fix completions
    # The previous setting of config.home.homeDirectory was incorrect and broke completions
    dotDir = lib.mkDefault "${config.xdg.configHome}/zsh";
    
    history = {
      size = lib.mkDefault 10000;
      share = lib.mkDefault true;
      ignoreDups = lib.mkDefault true;
      ignoreSpace = lib.mkDefault true;
    };
    
    defaultKeymap = lib.mkDefault "emacs";
    
    shellAliases = lib.mkDefault {
      ls = "eza --icons --group-directories-first";
      ll = "eza --long --icons --group-directories-first --git";
      la = "eza --all --icons --group-directories-first";
    };
    
    initContent = lib.mkDefault ''
      # Completion configuration
      # Prevent full path expansion - keep relative paths
      zstyle ':completion:*' keep-prefix yes
      zstyle ':completion:*' preserve-prefix yes
      zstyle ':completion:*' expand 'no'
      zstyle ':completion:*' special-dirs false
      
      # File completion - keep paths relative
      zstyle ':completion:*' file-sort modification
      zstyle ':completion:*' list-suffixes yes
      
      # Completion behavior
      setopt complete_in_word
      setopt no_auto_param_slash
      setopt no_complete_aliases
      
      # Initialize zoxide
      if command -v zoxide > /dev/null; then
        eval "$(zoxide init zsh)"
      fi
      
      # Initialize fzf
      if command -v fzf > /dev/null; then
        source <(fzf --zsh)
      fi
    '';
  };
  
  # Tmux
  programs.tmux = {
    enable = lib.mkDefault true;
    prefix = lib.mkDefault "C-space";
    baseIndex = lib.mkDefault 1;
    mouse = lib.mkDefault true;
    aggressiveResize = lib.mkDefault true;
    clock24 = lib.mkDefault true;
    escapeTime = lib.mkDefault 0;
    historyLimit = lib.mkDefault 10000;
    keyMode = lib.mkDefault "vi";
    terminal = lib.mkDefault "screen-256color";
    
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      vim-tmux-navigator
    ];
    
    extraConfig = lib.mkDefault ''
      set -g pane-base-index 1
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %
      
      # Vim-style navigation
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R
      
      # Copy mode
      setw -g mode-keys vi
      bind-key -T copy-mode-vi v send-keys -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
      
      # Status bar
      set -g status-position bottom
      set -g status-left "#[fg=green]#S "
      set -g status-right "#[fg=cyan]%Y-%m-%d %H:%M "
      
      setw -g automatic-rename on
      set -g renumber-windows on
    '';
  };
}

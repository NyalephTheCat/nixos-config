{ config, ... }:

{
  programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
      ll = "ls -l";
      la = "ls -la";
      ".." = "cd ..";
      "..." = "cd ../..";
      gc = "git commit";
      gs = "git status";
      ga = "git add";
      gd = "git diff";
      gp = "git push";
      gl = "git log --oneline --graph";
    };
    initExtra = ''
      # Custom prompt
      PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
      
      # Better history
      export HISTCONTROL=ignoredups:erasedups
      export HISTSIZE=10000
      export HISTFILESIZE=10000
      shopt -s histappend
      
      # Enable vi mode
      set -o vi
    '';
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    
    shellAliases = {
      ll = "ls -l";
      la = "ls -la";
      ".." = "cd ..";
      "..." = "cd ../..";
      gc = "git commit";
      gs = "git status";
      ga = "git add";
      gd = "git diff";
      gp = "git push";
      gl = "git log --oneline --graph";
    };
    
    history = {
      size = 10000;
      save = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };
    
    initExtra = ''
      # Enable vi mode
      bindkey -v
      
      # Better key bindings
      bindkey '^R' history-incremental-search-backward
      bindkey '^S' history-incremental-search-forward
      bindkey '^A' beginning-of-line
      bindkey '^E' end-of-line
    '';
    
    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [ "git" "docker" "kubectl" "systemd" ];
    };
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      format = ''
        [┌───────────────────>](bold green)
        [│](bold green)$username$hostname$directory$git_branch$git_status$nix_shell
        [└─>](bold green) 
      '';
      
      username = {
        show_always = true;
        format = "[$user]($style) in ";
      };
      
      hostname = {
        ssh_only = false;
        format = "[$hostname]($style) ";
      };
      
      directory = {
        truncation_length = 3;
        truncate_to_repo = false;
      };
      
      git_branch = {
        format = "on [$branch]($style) ";
      };
      
      nix_shell = {
        format = "via [$symbol$state]($style) ";
        symbol = "❄️ ";
      };
    };
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
  };

  programs.eza = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    git = true;
    icons = true;
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      pager = "less -FR";
    };
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
}

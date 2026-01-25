{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.tools.git;
in
{
  options.tools.git = {
    enable = mkEnableOption "Git";

    userName = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Git user name";
    };

    userEmail = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Git user email";
    };
  };

  config = mkIf cfg.enable {
    # Configure Home Manager's programs.git using the new settings API
    programs.git = {
      enable = true;
      
      # Git LFS
      lfs.enable = true;
      
      # All git configuration goes in settings
      settings = {
        # User identity
        user = {
          name = cfg.userName;
          email = cfg.userEmail;
        };
        
        # Init settings
        init = {
          defaultBranch = "main";
        };
        
        # Pull behavior
        pull = {
          rebase = true;
        };
        
        # Push behavior
        push = {
          autoSetupRemote = true;
          default = "simple";
        };
        
        # Core settings
        core = {
          editor = "vim";
          autocrlf = "input"; # Use LF line endings, convert CRLF to LF on commit
          ignorecase = false;
        };
        
        # Color settings
        color = {
          ui = true;
          branch = {
            current = "yellow reverse";
            local = "yellow";
            remote = "green";
          };
          diff = {
            meta = "yellow bold";
            frag = "magenta bold";
            old = "red bold";
            new = "green bold";
          };
          status = {
            added = "yellow";
            changed = "green";
            untracked = "cyan";
          };
        };
        
        # Diff settings
        diff = {
          algorithm = "histogram";
          colorMoved = "default";
          tool = "vimdiff";
        };
        
        # Merge settings
        merge = {
          tool = "vimdiff";
          conflictstyle = "diff3";
        };
        
        # Alias definitions
        alias = {
          # Status shortcuts
          st = "status";
          stat = "status";
          
          # Branch shortcuts
          br = "branch";
          co = "checkout";
          sw = "switch";
          
          # Commit shortcuts
          ci = "commit";
          ca = "commit -a";
          amend = "commit --amend";
          
          # Log shortcuts
          lg = "log --oneline --decorate --graph";
          lga = "log --oneline --decorate --graph --all";
          ll = "log --pretty=format:'%h - %an, %ar : %s'";
          
          # Diff shortcuts
          d = "diff";
          dc = "diff --cached";
          
          # Fetch/Pull/Push shortcuts
          f = "fetch";
          p = "push";
          pu = "push -u";
          
          # Stash shortcuts
          ss = "stash save";
          sp = "stash pop";
          sl = "stash list";
          
          # Reset shortcuts
          unstage = "reset HEAD --";
          uncommit = "reset --soft HEAD~1";
          
          # Other useful aliases
          who = "shortlog -sn";
          visual = "!vim";
          last = "log -1 HEAD";
          recent = "for-each-ref --sort=-committerdate refs/heads/ --format='%(refname:short)'";
          cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master\\|develop' | xargs -n 1 git branch -d";
        };
        
        # Credential helper
        credential = {
          helper = "store";
        };
        
        # Rebase settings
        rebase = {
          autoStash = true;
          autoSquash = true;
        };
        
        # Submodule settings
        submodule = {
          recurse = true;
        };
        
        # Protocol settings
        protocol = {
          version = "2";
        };
        
        # Performance settings
        feature = {
          experimental = true;
        };
        
        fetch = {
          parallel = 0;
        };
        
        # Safe directory (for worktrees)
        safe = {
          directory = "*";
        };
      };
    };
  };
}

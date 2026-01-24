{ config, pkgs, lib, ... }:

{
  # Git configuration - parameterized by user info
  # This should be imported and overridden with user-specific values
  # Note: extraConfig has been renamed to settings
  programs.git = {
    enable = lib.mkDefault true;
    settings = {
      init.defaultBranch = lib.mkDefault "main";
      pull.rebase = lib.mkDefault false;
      core.editor = lib.mkDefault "vim";
      color.ui = lib.mkDefault true;
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        cp = "cherry-pick";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "!gitk";
      };
    };
  };
}


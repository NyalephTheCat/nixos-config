{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "Chloe Magnier"; # Replace with your actual name
    userEmail = "chloe@magnier.dev"; # Replace with your email

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      fetch.prune = true;
      diff.colorMoved = "default";
      merge.conflictstyle = "diff3";
    };

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      lg = "log --oneline --graph --decorate";
    };
  };
}

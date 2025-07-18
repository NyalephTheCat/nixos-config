{ ... }:

{
  programs.git = {
    enable = true;
    userName = "nyaleph";
    userEmail = "chloe@magnier.dev";
    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
    };
  };
}

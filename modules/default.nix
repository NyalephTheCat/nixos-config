{ inputs, pkgs, config, ... }:

{
  home.stateVersion = "21.03";
  imports = [
    # Config settings
    ./config

    # The rest here
    ./firefox
    ./discord
    ./zsh
    ./gnome
    ./nvim
    ./kitty
    ./thunderbird
    ./steam
    ./documents
    ./docker
  ];
}

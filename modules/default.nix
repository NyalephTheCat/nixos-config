{ inputs, pkgs, config, ... }:

{
    home.stateVersion = "21.03";
    imports = [
        # gui
        ./firefox
        ./kitty
        ./foot
        ./eww
        ./dunst
        ./hyprland
        ./wofi
        ./discord

        # cli
        ./nvim
        ./bat
        ./zsh
        ./git
        ./gpg
        ./direnv

        # system
        ./xdg
	    ./packages
  
        # Tools
        ./rust
  ];
}

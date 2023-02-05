{ config, lib, inputs, ...}:

{
    imports = [ ../../modules/default.nix ];
    config.modules = {
        # gui
        firefox.enable = true;
        kitty.enable = true;
        foot.enable = true;
        eww.enable = true;
        dunst.enable = true;
        hyprland.enable = true;
        wofi.enable = true;
        discord.enable = true;

        # cli
        nvim.enable = true;
        bat.enable = true;
        zsh.enable = true;
        git.enable = true;
        gpg.enable = true;
        direnv.enable = true;

        # system
        xdg.enable = true;
        packages.enable = true;
        
        # Tools
        rust.enable = true;
      };
}

{ config, pkgs, lib, ... }:

{
  # System-wide program configurations
  # These configure programs available to all users
  
  programs.firefox.enable = lib.mkDefault true;
  
  programs.steam = lib.mkDefault {
    enable = false; # Disabled by default, enable in gaming module
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  
  programs.gnupg.agent = {
    enable = lib.mkDefault true;
    enableSSHSupport = lib.mkDefault true;
  };
  
  programs.mtr.enable = lib.mkDefault true;
  programs.wireshark.enable = lib.mkDefault true;

  # Modern CLI tools
  # Note: eza, zoxide, fzf are installed as packages in base.nix
  # Only enable program configurations for tools that have NixOS system-level support
  programs.bat.enable = lib.mkDefault true;
  programs.direnv.enable = lib.mkDefault false; # Enable in development feature
  programs.nix-index.enable = lib.mkDefault true;
  
  # Zsh as default shell
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableBashCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    
    ohMyZsh = {
      enable = true;
      plugins = [
        "git" "docker" "kubectl" "rust" "python" "node"
        "npm" "yarn" "history" "colored-man-pages"
        "command-not-found" "extract" "sudo" "z"
      ];
      theme = lib.mkDefault "robbyrussell";
    };

    shellAliases = {
      ll = "ls -lah";
      la = "ls -A";
      l = "ls -l";
      ".." = "cd ..";
      "..." = "cd ../..";
      grep = "grep --color=auto";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      d = "docker";
      dc = "docker-compose";
      dps = "docker ps";
      dimg = "docker images";
      nrs = "sudo nixos-rebuild switch --flake .";
      nrb = "sudo nixos-rebuild boot --flake .";
      nrgc = "sudo nix-collect-garbage -d";
    };
  };

  users.defaultUserShell = pkgs.zsh;
}


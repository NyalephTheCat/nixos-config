{ config, pkgs, lib, ... }:

{
  # Additional shell aliases
  # These complement the system-wide aliases in programs.zsh
  programs.zsh.shellAliases = lib.mkIf config.programs.zsh.enable {
    # Modern CLI tool aliases
    cat = "bat";
    ls = "eza";
    ll = "eza -l";
    la = "eza -la";
    tree = "eza --tree";
    find = "fd";
    grep = "rg";
    cd = "z";
    
    # Git aliases (additional to system-wide)
    gco = "git checkout";
    gcb = "git checkout -b";
    gst = "git status";
    gaa = "git add --all";
    gcm = "git commit -m";
    gca = "git commit --amend";
    glog = "git log --oneline --graph --decorate";
    gpl = "git pull";
    gps = "git push";
    gpf = "git push --force-with-lease";
    
    # Docker aliases (additional to system-wide)
    dcu = "docker-compose up";
    dcd = "docker-compose down";
    dce = "docker-compose exec";
    dcl = "docker-compose logs";
    dcb = "docker-compose build";
    
    # NixOS aliases (additional to system-wide)
    nrsf = "sudo nixos-rebuild switch --flake .";
    nrb = "sudo nixos-rebuild boot --flake .";
    nrt = "sudo nixos-rebuild test --flake .";
    nrgc = "sudo nix-collect-garbage -d";
    nrf = "nix flake";
    nrfup = "nix flake update";
    nrfch = "nix flake check";
    
    # System utilities
    htop = "btop";
    top = "btop";
    ps = "procs";
    du = "dust";
    df = "duf";
    
    # Quick navigation
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    
    # Safety aliases
    rm = "rm -i";
    mv = "mv -i";
    cp = "cp -i";
    
    # Editor
    v = "vim";
    vi = "vim";
  };
}


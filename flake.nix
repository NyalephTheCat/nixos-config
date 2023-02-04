{
  description = "NixOS Configuration for my machine";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    lanzaboote.url = "github:nix-community/lanzaboote/65896e03fa64c5a430ced5a41c1cb403f0b6f090";
    # hyprland.url = "github:hyprwm/Hyprland";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    kittyNixpkgs.url = "github:NixOS/nixpkgs/c28f3f4bb3c1b7c723c1bf9e012704d89888aeff";
  };
  outputs = { 
    nixpkgs, 
    nixos-hardware, 
    lanzaboote, 
    # hyprland, 
    home-manager, ...
  }@inputs: {
    nixosConfigurations."nixos" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # hyprland.nixosModules.default
        lanzaboote.nixosModules.lanzaboote
        home-manager.nixosModules.home-manager
        nixos-hardware.nixosModules.lenovo-thinkpad-t470s
        ./hardware-configuration.nix
        ./configuration.nix
        ./home.nix
      ];
      specialArgs = inputs // {
        isNotWSL = true;
        kitty = nixpkgs.legacyPackages."x86_64-linux".kitty;
      };
    };
  };
}

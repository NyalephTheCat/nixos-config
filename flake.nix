{
  description = "NixOS Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    lanzaboote.url = "github:nix-community/lanzaboote/65896e03fa64c5a430ced5a41c1cb403f0b6f090";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kittyNixpkgs.url = "github:NixOS/nixpkgs/c28f3f4bb3c1b7c723c1bf9e012704d89888aeff";
  };

  outputs = { home-manager, nixpkgs, nur, lanzaboote, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
      lib = nixpkgs.lib;
      mkSystem = pkgs: system: hostname:
        pkgs.lib.nixosSystem {
          system = system;
          modules = [
            { networking.hostname = hostname; }
            ./modules/system/configuration.nix
            # DO NOT USE MY HARDWARE CONFIG
            ( ./. + "hosts/${hostname}/hardware-configuration.nix")
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useUserPackages = true;
                useGlobalPkgs = true;
                extraSpecialArgs = { inherit inputs; };
                user.chloe = (./. + "/hosts/${hostname}/user.nix");
              };
              nixpkgs.overlays = [
                nur.overlay
              ];
            }
          ];
          specialArgs = { inherit inputs; };
        };
      in {
        nixosConfigurations = {
          nyxos = mkSystem inputs.nixpkgs "x86_64-linux" "nyxos";
        };
      };
}

{
  description = "NixOS configuration for veilkeepers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
  let
    helpers = import ./lib/helpers.nix { lib = nixpkgs.lib; };
  in
  {
    nixosConfigurations = {
      veilkeepers = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs helpers; };
        modules = [
          ./hosts/veilkeepers
          ./modules/nixos
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.nyaleph = import ./home/nyaleph;
              extraSpecialArgs = { inherit inputs helpers; };
            };
          }
        ];
      };
    };

    homeConfigurations = {
      nyaleph = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs helpers; };
        modules = [
          ./home/nyaleph
        ];
      };
    };
  };
}

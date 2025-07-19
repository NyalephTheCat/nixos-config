{
  description = "NixOS configuration for veilkeepers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }@inputs:
    let helpers = import ./lib/helpers.nix { lib = nixpkgs.lib; };
    in {
      nixosConfigurations = {
        veilkeepers = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs helpers; };
          modules = [
            ./hosts/veilkeepers
            ./modules/nixos
            home-manager.nixosModules.home-manager
            # This is technically incorrect but it's close enough
            nixos-hardware.nixosModules.omen-16-n0280nd
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
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          extraSpecialArgs = { inherit inputs helpers; };
          modules = [ ./home/nyaleph ];
        };
      };
    };
}

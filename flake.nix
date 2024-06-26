{
  description = "Nyaleph's NixOS Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    lanzaboote.url = "github:nix-community/lanzaboote";

    rust-overlay.url = "github:oxalica/rust-overlay";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, lanzaboote, rust-overlay, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    lib = nixpkgs.lib;
    mkSystem = pkgs: system: hostname:
      pkgs.lib.nixosSystem {
        system = system;
        modules = [
          { networking.hostName = hostname; }
          { nixpkgs.config.allowUnfree = true; }
          lanzaboote.nixosModules.lanzaboote
          home-manager.nixosModules.home-manager
          ./modules/system
          ({ pkgs, ... }: {
            nixpkgs.overlays = [ rust-overlay.overlays.default ];
            environment.systemPackages = [
              (pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default))
            ];
          })
          # Don't forget to create default.nix, and to copy your own hardawre-configuration.nix
          (./. + "/hosts/${hostname}/hardware-configuration.nix")
          {
            nixpkgs.overlays = [ (import ./overlays/electron.nix) ];
            home-manager = {
              useUserPackages = true;
              useGlobalPkgs = true;
              extraSpecialArgs = { inherit inputs; };
              users.chloe = (./. + "/hosts/${hostname}/user.nix");
            };
          }
        ];
        specialArgs = { inherit inputs; };
      };
  in
  {
    nixosConfigurations = {
      nox = mkSystem inputs.nixpkgs "x86_64-linux" "nox";
      nixos = mkSystem inputs.nixpkgs "x86_64-linux" "nixos";
    };
  };
}

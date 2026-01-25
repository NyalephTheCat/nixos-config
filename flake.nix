{
  description = "NixOS and Home Manager configuration for heaven and agz-pc";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux";
      
      # Extend lib with home-manager's lib.hm
      libWithHm = if home-manager ? lib && home-manager.lib ? hm
        then nixpkgs.lib.extend (final: prev: { hm = home-manager.lib.hm; })
        else nixpkgs.lib.extend (final: prev: {
          hm = {
            deprecations = {
              mkSettingsRenamedOptionModules = basePath: newPath: transform: [];
            };
            strings = {
              toKebabCase = x: nixpkgs.lib.toLower (nixpkgs.lib.replaceStrings ["_"] ["-"] x);
            };
          };
        });
      
      lib = libWithHm;
      
      # Workaround: Create a module that extends lib with lib.hm
      # This must be evaluated before home-manager modules
      libHmWorkaround = { lib, ... }: {
        # Extend lib in the module evaluation context
        _module.args.lib = lib.extend (final: prev: {
          hm = (home-manager.lib or {}).hm or prev.hm or {
            deprecations = {
              mkSettingsRenamedOptionModules = basePath: newPath: transform: [];
            };
            strings = {
              toKebabCase = x: lib.toLower (lib.replaceStrings ["_"] ["-"] x);
            };
          };
        });
      };
      
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      customUtils = import ./lib/utils.nix { inherit pkgs lib; };
      
      # Helper function to create a NixOS configuration
      # Use libWithHm for nixosSystem so the extended lib is used throughout
      mkHost = hostName: libWithHm.nixosSystem {
        inherit system;
        modules = [
          # CRITICAL: This must come FIRST to extend lib before home-manager modules evaluate
          libHmWorkaround
          (./hosts/${hostName}/default.nix)
          home-manager.nixosModules.home-manager
        ];
        specialArgs = { inherit pkgs inputs customUtils; };
      };
    in
    {
      nixosConfigurations = {
        heaven = mkHost "heaven";
        agz-pc = mkHost "agz-pc";
      };

      # Export utility functions
      lib = customUtils;
    };
}


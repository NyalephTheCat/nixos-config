{
  description = "Multi-host NixOS configuration with Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Optional: nixos-hardware for better hardware support
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    # Optional: sops-nix for secrets management
    # sops-nix = {
    #   url = "github:Mic92/sops-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }@inputs:
    let
      # Helper functions from lib
      inherit (nixpkgs) lib;
      
      # Import custom library functions
      customLib = import ./lib/default.nix { inherit lib inputs; };
      
      # Load overlays
      overlays = import ./overlays/default.nix;
      
      # Load custom packages (if any) - will be available via specialArgs
      customPackages = import ./pkgs/default.nix { pkgs = nixpkgs.legacyPackages.x86_64-linux; };
      
      # Helper to create a NixOS system configuration with per-host customization
      mkHost = hostname: { system ? "x86_64-linux", users ? [], nixpkgsConfig ? {}, hardwareModules ? [], extraModules ? [] }:
        let
          # Import host-specific nixpkgs config if it exists
          hostNixpkgsConfig = if builtins.pathExists ./hosts/${hostname}/nixpkgs.nix
            then import ./hosts/${hostname}/nixpkgs.nix { inherit lib; }
            else {};
          
          # Merge nixpkgs config (host-specific overrides defaults)
          mergedNixpkgsConfig = lib.recursiveUpdate {
            allowUnfree = true;
            permittedInsecurePackages = [];
          } (lib.recursiveUpdate hostNixpkgsConfig nixpkgsConfig);
          
          # Create nixpkgs with overlays and config
          pkgsForSystem = import nixpkgs {
            inherit system;
            config = mergedNixpkgsConfig;
            overlays = overlays;
          };
        in
        customLib.mkHost {
          inherit hostname system;
          users = users;
          hostConfigPath = ./hosts/${hostname}/configuration.nix;
          hardwareConfigPath = ./hosts/${hostname}/hardware-configuration.nix;
          featuresPath = ./hosts/${hostname}/features.nix;
          userConfigPaths = lib.genAttrs users (user: ./users/${user}/home.nix);
          modules = extraModules ++ [
            # Per-host nixpkgs configuration
            # Note: nixpkgs.config is passed when creating pkgsForSystem, don't set it here
            {
              nixpkgs.pkgs = pkgsForSystem;
            }
            
            # Make custom packages available via specialArgs
            {
              _module.args.customPackages = customPackages;
            }
          ] ++ lib.optional (hardwareModules != []) {
            # nixos-hardware integration (can be enabled per-host via hardwareModules)
            imports = hardwareModules;
          };
        };
    in
    {
      # NixOS configurations for each host
      nixosConfigurations = {
        # heaven - nyaleph's system
        heaven = mkHost "heaven" {
          system = "x86_64-linux";
          users = [ "nyaleph" ];
          # Optional: Add per-host nixpkgs config, hardware modules, etc.
          # nixpkgsConfig = { allowUnfree = true; };
          # hardwareModules = [ nixos-hardware.nixosModules.common-cpu-amd ];
        };
        
        # agz-pc - agz's system
        agz-pc = mkHost "agz-pc" {
          system = "x86_64-linux";
          users = [ "agz-cadentis" ];
          # Optional: Add per-host nixpkgs config, hardware modules, etc.
          # nixpkgsConfig = { allowUnfree = true; };
          # hardwareModules = [ nixos-hardware.nixosModules.common-cpu-amd ];
        };
      };

      # Helper for building specific host
      # Usage: nix build .#heaven or nix build .#agz-pc
      # Note: Packages are organized by system architecture
      # To add support for other architectures, add entries like:
      # packages.aarch64-linux = { ... };
      packages.x86_64-linux = {
        heaven = self.nixosConfigurations.heaven.config.system.build.toplevel;
        agz-pc = self.nixosConfigurations.agz-pc.config.system.build.toplevel;
      };

      # Development shell with useful tools
      devShells.x86_64-linux.default = nixpkgs.legacyPackages.x86_64-linux.mkShell {
        buildInputs = with nixpkgs.legacyPackages.x86_64-linux; [
          nixpkgs-fmt
          nil # Nix LSP
          statix # Nix linter
        ];
        
        shellHook = ''
          echo "NixOS Multi-Host Configuration"
          echo "Available hosts:"
          echo "  - heaven (nyaleph)"
          echo "  - agz-pc (agz-cadentis)"
          echo ""
          echo "Commands:"
          echo "  - sudo nixos-rebuild switch --flake .#heaven"
          echo "  - sudo nixos-rebuild switch --flake .#agz-pc"
          echo "  - nix flake check"
          echo "  - nix flake update"
        '';
      };
    };
}


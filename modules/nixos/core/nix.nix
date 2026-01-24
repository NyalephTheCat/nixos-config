{ config, pkgs, lib, ... }:

{
  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Binary cache settings for faster builds
  nix.settings = {
    # Use binary caches for faster package installation
    substituters = lib.mkDefault [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
    ];
    trusted-public-keys = lib.mkDefault [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nixpkgs-wayland.cachix.org-1:3lwxaZxHgJ0AEW78rsRLg7H2VqDp3dFleWfAXnqUiEJ="
    ];
    # Auto-optimise store to save disk space
    auto-optimise-store = lib.mkDefault true;
    # Allow building with sandboxed builds (more secure)
    sandbox = lib.mkDefault true;
    # Build performance settings (can be overridden per-host)
    max-jobs = lib.mkDefault "auto";
    cores = lib.mkDefault 0; # 0 = use all available cores
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Nixpkgs configuration
  # Note: Per-host nixpkgs configuration is set in flake.nix when creating the nixpkgs instance.
  # Do not set nixpkgs.config here as it's handled in flake.nix via mkHost.
  # - flake.nix: mkHost "hostname" { nixpkgsConfig = { ... }; }
  # - hosts/hostname/nixpkgs.nix: { allowUnfree = true; }
}

# Overlay Usage Documentation
# 
# Overlays are defined in overlays/default.nix and automatically applied in flake.nix.
# To use overlays in modules:
#
# 1. Overlays are applied at the nixpkgs level, so packages in modules automatically
#    use the overlaid versions.
#
# 2. To access custom packages from pkgs/, use specialArgs.customPackages:
#    { config, pkgs, customPackages, ... }:
#    {
#      environment.systemPackages = [ customPackages.myCustomPackage ];
#    }
#
# 3. To add per-host overlays, use the host.overlays option or set them in flake.nix:
#    mkHost "hostname" {
#      # Additional overlays for this host
#      extraModules = [{
#        nixpkgs.overlays = [ (final: prev: { ... }) ];
#      }];
#    }
#
# 4. Package overrides can be done via:
#    - Overlays (recommended for reusable overrides)
#    - config.packageOverrides (per-host overrides)
#    - Direct override in module using lib functions from lib/packages.nix


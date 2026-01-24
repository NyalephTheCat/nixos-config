{ pkgs, lib, ... }:

{
  # Custom package definitions
  # Add your custom packages here
  #
  # Structure:
  # - Each custom package should be in its own directory under pkgs/
  # - Use callPackage pattern for proper dependency injection
  # - Document each package with comments
  #
  # Example:
  # myCustomPackage = pkgs.callPackage ./my-custom-package {
  #   # Dependencies can be overridden here
  #   someDep = pkgs.someDep;
  # };
  #
  # To use custom packages in modules:
  # - They are available via specialArgs.customPackages
  # - Or add them to an overlay in overlays/default.nix
  # - Or import them directly in your module
}


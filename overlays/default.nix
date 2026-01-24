# Package overlays to modify existing packages
# Overlays are applied in order, so later overlays can override earlier ones
#
# Usage examples:
#
# 1. Override package version:
#    final: prev: {
#      myPackage = prev.myPackage.overrideAttrs (old: {
#        version = "custom";
#        src = prev.fetchFromGitHub { ... };
#      });
#    }
#
# 2. Patch a package:
#    final: prev: {
#      myPackage = prev.myPackage.overrideAttrs (old: {
#        patches = (old.patches or []) ++ [
#          ./patches/my-package-fix.patch
#        ];
#      });
#    }
#
# 3. Change build flags:
#    final: prev: {
#      myPackage = prev.myPackage.override {
#        enableFeature = true;
#      };
#    }
#
# 4. Add custom packages:
#    final: prev: {
#      myCustomPackage = prev.callPackage ../pkgs/my-custom-package {};
#    }

[
  # Add your overlays here
  # Example structure:
  # (final: prev: {
  #   # Your overlay code
  # })
]


{ config, pkgs, lib, customUtils, ... }:

# Note: cursor is not available in nixpkgs by default
# If you need cursor, you can add it via an overlay or install it manually
# For now, we'll create a placeholder that can be overridden
(customUtils.mkMultipleApps [
  # { name = "cursor"; defaultPackage = pkgs.cursor; description = "Cursor IDE"; }
]) { inherit config pkgs lib; }


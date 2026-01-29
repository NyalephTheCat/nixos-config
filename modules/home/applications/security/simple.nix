{ config, pkgs, lib, customUtils, ... }:

# Security applications using mkMultipleApps helper
(customUtils.mkMultipleApps [
  { name = "keepassxc"; defaultPackage = pkgs.keepassxc; description = "KeePassXC password manager"; }
  # Note: authy not available in nixpkgs - use alternative 2FA apps
  { name = "bitwarden"; defaultPackage = pkgs.bitwarden-desktop; description = "Bitwarden password manager"; packageName = "bitwarden-desktop"; }
  { name = "gnupg"; defaultPackage = pkgs.gnupg; description = "GNU Privacy Guard"; }
]) { inherit config pkgs lib; }

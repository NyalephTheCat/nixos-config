{ config, pkgs, lib, ... }:

let
  cfg = config.features.gaming or { enable = false; };
in
{
  config = lib.mkIf cfg.enable {
    # Gamemode for gaming performance optimization
    programs.gamemode = {
      enable = true;
      settings = {
        general = {
          renice = 10;
        };
        gpu = {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_device = 0;
          amd_performance_level = lib.mkIf ((config.features.hardware.gpu or "amd") == "amd") "high";
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };

    # MangoHud for performance overlay (installed as package)
    # Note: MangoHud doesn't have a programs.mangohud option, it's just a package

    # Steam gaming platform
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    # Retro gaming emulators and gaming tools
    environment.systemPackages = with pkgs; [
      retroarch    # Retro game emulator
      # duckstation  # PlayStation emulator (temporarily disabled - hash mismatch issue)
      # Note: duckstation may not be available in current nixpkgs
      # If you need it, try: nix-env -iA nixpkgs.duckstation or install via flatpak
      mangohud     # Performance overlay for games
    ];

    # Hytale launcher installation via Flatpak
    systemd.services.hytale-launcher-install = {
      description = "Install Hytale Launcher Flatpak";
      wantedBy = [ "multi-user.target" ];
      after = [ "flatpak.service" "network-online.target" ];
      wants = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StateDirectory = "hytale-installer";
        ExecStart = pkgs.writeShellScript "install-hytale" ''
          set -euo pipefail
          
          FLATPAK_URL="https://launcher.hytale.com/builds/release/linux/amd64/hytale-launcher-latest.flatpak"
          STATE_DIR="/var/lib/hytale-installer"
          INSTALLED_MARKER="$STATE_DIR/.hytale-installed"
          
          # Check if already installed
          if [ -f "$INSTALLED_MARKER" ]; then
            echo "Hytale launcher already installed, skipping..."
            exit 0
          fi
          
          # Check if flatpak is already installed (system-wide)
          if ${pkgs.flatpak}/bin/flatpak list --system --app --columns=application 2>/dev/null | grep -q "com.hytale.launcher" || \
             ${pkgs.flatpak}/bin/flatpak list --user --app --columns=application 2>/dev/null | grep -q "com.hytale.launcher"; then
            echo "Hytale launcher already installed via flatpak, marking as complete..."
            touch "$INSTALLED_MARKER"
            exit 0
          fi
          
          # Download the flatpak
          echo "Downloading Hytale launcher..."
          TEMP_FILE=$(mktemp)
          ${pkgs.curl}/bin/curl -L -o "$TEMP_FILE" "$FLATPAK_URL"
          
          # Install the flatpak bundle system-wide
          echo "Installing Hytale launcher..."
          ${pkgs.flatpak}/bin/flatpak install --system --bundle --assumeyes "$TEMP_FILE" || {
            echo "Installation failed, cleaning up..."
            rm -f "$TEMP_FILE"
            exit 1
          }
          
          # Clean up and mark as installed
          rm -f "$TEMP_FILE"
          touch "$INSTALLED_MARKER"
          echo "Hytale launcher installed successfully!"
        '';
      };
    };
  };
}


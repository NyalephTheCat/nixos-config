{ config, pkgs, ... }:

{
  # Enable Plasma6 desktop environment
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Plasma6 packages
  # Note: Package exclusion for Plasma6 - adjust as needed
  # These packages might need to be referenced differently depending on nixpkgs version
  environment.plasma6.excludePackages = with pkgs; [
    # Add packages to exclude here if needed
    # Example: libsForQt6.elisa
  ];

  # Enable sound (sound.enable is deprecated, use hardware.alsa if needed)
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # KDE Connect - connect phone to desktop (opens firewall ports 1714-1764)
  programs.kdeconnect.enable = true;
}


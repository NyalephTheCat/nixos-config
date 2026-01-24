{ config, pkgs, lib, ... }:

{
  # Audio system configuration
  # Pipewire replaces PulseAudio and provides better audio handling
  services.pulseaudio.enable = false; # Disable PulseAudio (replaced by Pipewire)
  security.rtkit.enable = true; # Real-time scheduling for audio
  services.pipewire = {
    enable = true;
    alsa.enable = true; # ALSA support
    alsa.support32Bit = true; # 32-bit application support
    pulse.enable = true; # PulseAudio compatibility layer
    # JACK support (uncomment if needed for professional audio)
    # jack.enable = true;
  };
}


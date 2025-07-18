{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.audio;
in
{
  options.modules.desktop.audio = {
    enable = mkEnableOption "audio support";
    
    backend = mkOption {
      type = types.enum [ "pipewire" "pulseaudio" ];
      default = "pipewire";
      description = "Audio backend to use";
    };
    
    lowLatency = {
      enable = mkEnableOption "low latency audio for music production";
      
      quantum = mkOption {
        type = types.int;
        default = 64;
        description = "Buffer size for low latency";
      };
      
      rate = mkOption {
        type = types.int;
        default = 48000;
        description = "Sample rate";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # Common audio configuration
    {
      # Enable realtime kit for better audio performance
      security.rtkit.enable = true;
      
      # Common audio packages
      environment.systemPackages = with pkgs; [
        pavucontrol
        pamixer
        pulseaudio # for pactl
      ] ++ optionals (cfg.backend == "pipewire") [
        pw-volume
        helvum # Pipewire patchbay
        easyeffects
      ];
    }
    
    # PipeWire configuration
    (mkIf (cfg.backend == "pipewire") {
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        jack.enable = true;
        
        extraConfig.pipewire = mkIf cfg.lowLatency.enable {
          "99-lowlatency" = {
            "context.properties" = {
              "default.clock.rate" = cfg.lowLatency.rate;
              "default.clock.quantum" = cfg.lowLatency.quantum;
              "default.clock.min-quantum" = cfg.lowLatency.quantum;
              "default.clock.max-quantum" = cfg.lowLatency.quantum;
            };
          };
        };
      };
      
      # Disable PulseAudio since we're using PipeWire
      services.pulseaudio.enable = false;
    })
    
    # PulseAudio configuration
    (mkIf (cfg.backend == "pulseaudio") {
      services.pulseaudio = {
        enable = true;
        support32Bit = true;
        daemon.config = {
          default-sample-rate = cfg.lowLatency.rate;
          alternate-sample-rate = cfg.lowLatency.rate;
          default-fragments = mkIf cfg.lowLatency.enable "2";
          default-fragment-size-msec = mkIf cfg.lowLatency.enable "2";
        };
      };
      
      # Disable PipeWire since we're using PulseAudio
      services.pipewire.enable = false;
    })
  ]);
}
{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.media;
in
{
  options.modules.desktop.media = {
    enable = mkEnableOption "media applications";
    
    players = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable media players";
      };
      
      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          vlc
          mpv
          celluloid # GTK+ frontend for mpv
        ];
        description = "Media player packages to install";
      };
    };
    
    audio = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable audio tools";
      };
      
      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          audacity
          spotify
          lollypop
        ];
        description = "Audio application packages";
      };
    };
    
    video = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable video tools";
      };
      
      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          kdePackages.kdenlive
          obs-studio
          handbrake
          ffmpeg-full
        ];
        description = "Video application packages";
      };
    };
    
    images = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable image tools";
      };
      
      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          gimp
          inkscape
          krita
          eog # Eye of GNOME image viewer
          kdePackages.gwenview # KDE image viewer
        ];
        description = "Image application packages";
      };
    };
    
    codecs = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable multimedia codecs";
      };
      
      packages = mkOption {
        type = types.listOf types.package;
        default = with pkgs; [
          gst_all_1.gstreamer
          gst_all_1.gst-plugins-base
          gst_all_1.gst-plugins-good
          gst_all_1.gst-plugins-bad
          gst_all_1.gst-plugins-ugly
          gst_all_1.gst-libav
          gst_all_1.gst-vaapi
        ];
        description = "Codec packages";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = 
      (optionals cfg.players.enable cfg.players.packages) ++
      (optionals cfg.audio.enable cfg.audio.packages) ++
      (optionals cfg.video.enable cfg.video.packages) ++
      (optionals cfg.images.enable cfg.images.packages) ++
      (optionals cfg.codecs.enable cfg.codecs.packages);
    
    # Enable hardware acceleration
    hardware.graphics = mkIf (cfg.video.enable || cfg.players.enable) {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vaapiIntel
        vaapiVdpau
        libvdpau-va-gl
      ];
    };
  };
}
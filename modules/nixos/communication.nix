{ config, lib, pkgs, helpers, ... }:
with lib;
let
  cfg = config.modules.communication;
  inherit (helpers) mkOptBool;
in {
  options.modules.communication = {
    enable = mkEnableOption "Communication and social applications";
    
    chat = {
      discord = mkOptBool true "Enable Discord";
      element = mkOptBool true "Enable Element (Matrix client)";
      signal = mkOptBool true "Enable Signal Desktop";
      slack = mkOptBool false "Enable Slack";
      telegram = mkOptBool false "Enable Telegram Desktop";
    };
    
    video = {
      zoom = mkOptBool true "Enable Zoom";
      teams = mkOptBool true "Enable Microsoft Teams";
      skype = mkOptBool false "Enable Skype";
      jitsi = mkOptBool false "Enable Jitsi Meet";
    };
    
    email = {
      thunderbird = mkOptBool true "Enable Thunderbird";
      evolution = mkOptBool false "Enable Evolution";
      mailspring = mkOptBool false "Enable Mailspring";
    };
    
    social = {
      mastodon = mkOptBool false "Enable Mastodon client";
      twitter = mkOptBool false "Enable Twitter client";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; 
      # Chat applications
      (optionals cfg.chat.discord [ discord ]) ++
      (optionals cfg.chat.element [ element-desktop ]) ++
      (optionals cfg.chat.signal [ signal-desktop ]) ++
      (optionals cfg.chat.slack [ slack ]) ++
      (optionals cfg.chat.telegram [ telegram-desktop ]) ++
      
      # Video conferencing
      (optionals cfg.video.zoom [ zoom-us ]) ++
      (optionals cfg.video.teams [ teams-for-linux ]) ++
      (optionals cfg.video.skype [ skypeforlinux ]) ++
      (optionals cfg.video.jitsi [ jitsi-meet-electron ]) ++
      
      # Email clients
      (optionals cfg.email.thunderbird [ thunderbird ]) ++
      (optionals cfg.email.evolution [ evolution ]) ++
      (optionals cfg.email.mailspring [ mailspring ]) ++
      
      # Social media
      (optionals cfg.social.mastodon [ tootle ]) ++
      (optionals cfg.social.twitter [ cawbird ]);
    
    # Open firewall for video conferencing if needed
    networking.firewall = mkIf (cfg.video.zoom || cfg.video.teams || cfg.video.skype) {
      allowedTCPPortRanges = [
        { from = 8801; to = 8810; } # Zoom
      ];
      allowedUDPPortRanges = [
        { from = 8801; to = 8810; } # Zoom
      ];
    };
  };
}

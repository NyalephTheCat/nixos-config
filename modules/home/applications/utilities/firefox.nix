{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.applications.firefox;
in
{
  options.applications.firefox = {
    enable = mkEnableOption "Firefox";

    package = mkOption {
      type = types.package;
      default = pkgs.firefox;
      defaultText = "pkgs.firefox";
      description = "The Firefox package to use.";
      example = "pkgs.firefox-wayland";
    };

    search = {
      defaultEngine = mkOption {
        type = types.str;
        default = "DuckDuckGo";
        description = "Default search engine.";
        example = "Google";
      };

      suggestions = {
        enabled = mkOption {
          type = types.bool;
          default = true;
          description = "Enable search suggestions.";
        };

        urlbar = mkOption {
          type = types.bool;
          default = true;
          description = "Enable search suggestions in the URL bar.";
        };
      };
    };

    privacy = {
      trackingProtection = mkOption {
        type = types.bool;
        default = true;
        description = "Enable enhanced tracking protection.";
      };

      resistFingerprinting = mkOption {
        type = types.bool;
        default = true;
        description = "Enable fingerprint resistance (may break some websites).";
      };

      httpsOnlyMode = mkOption {
        type = types.bool;
        default = true;
        description = "Enable HTTPS-only mode.";
      };

      webRTC = mkOption {
        type = types.bool;
        default = false;
        description = "Enable WebRTC (disabling prevents IP leak but breaks video calls).";
      };

      cookieBehavior = mkOption {
        type = types.enum [ 0 1 2 4 ];
        default = 1;
        description = "Cookie behavior: 0=accept all, 1=accept from visited, 2=block all, 4=block third-party.";
      };
    };

    telemetry = {
      enabled = mkOption {
        type = types.bool;
        default = false;
        description = "Enable telemetry (not recommended for privacy).";
      };
    };

    performance = {
      webRender = mkOption {
        type = types.bool;
        default = true;
        description = "Enable WebRender for better performance.";
      };

      hardwareAcceleration = mkOption {
        type = types.bool;
        default = true;
        description = "Enable hardware acceleration.";
      };
    };

    preferences = mkOption {
      type = types.attrsOf (types.oneOf [ types.str types.int types.bool ]);
      default = {
        # Search Engine
        "browser.search.defaultenginename" = "DuckDuckGo";
        "browser.search.selectedEngine" = "DuckDuckGo";
        "browser.search.suggest.enabled" = true;
        "browser.urlbar.suggest.searches" = true;

        # Startup
        "browser.startup.homepage" = "about:home";
        "browser.startup.page" = 1; # 0=blank, 1=home, 2=last, 3=resume
        "browser.newtabpage.enabled" = true;

        # Privacy & Tracking Protection
        "privacy.trackingprotection.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        "privacy.trackingprotection.cryptomining.enabled" = true;
        "privacy.trackingprotection.fingerprinting.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "privacy.donottrackheader.value" = 1;
        "privacy.purge_trackers.enabled" = true;
        "privacy.purge_trackers.date_in_cookie_database" = 0;

        # Cookies & Data
        "network.cookie.cookieBehavior" = 1; # 0=accept all, 1=accept from visited, 2=block all, 4=block third-party
        "network.cookie.lifetimePolicy" = 2; # 0=accept normally, 2=accept for session
        "network.cookie.thirdParty.sessionOnly" = true;
        "browser.contentblocking.category" = "strict";

        # Telemetry & Data Collection
        "toolkit.telemetry.enabled" = false;
        "toolkit.telemetry.server" = "";
        "toolkit.telemetry.archive.enabled" = false;
        "toolkit.telemetry.newProfilePing.enabled" = false;
        "toolkit.telemetry.shutdownPingSender.enabled" = false;
        "toolkit.telemetry.updatePing.enabled" = false;
        "toolkit.telemetry.bhrPing.enabled" = false;
        "toolkit.telemetry.firstShutdownPing.enabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.healthreport.service.enabled" = false;
        "browser.ping-centre.telemetry" = false;
        "browser.newtabpage.activity-stream.feeds.telemetry" = false;
        "browser.newtabpage.activity-stream.telemetry" = false;

        # Location & Permissions
        "geo.enabled" = false;
        "permissions.default.geo" = 2; # 0=allow, 1=block, 2=prompt
        "permissions.default.camera" = 2;
        "permissions.default.microphone" = 2;
        "permissions.default.desktop-notification" = 2;

        # Security
        "security.tls.insecure_fallback_hosts" = "";
        "security.ssl.require_safe_negotiation" = true;
        "security.ssl.treat_unsafe_negotiation_as_broken" = true;
        "security.mixed_content.block_display_content" = true;
        "security.mixed_content.block_active_content" = true;
        "dom.security.https_only_mode" = true;
        "dom.security.https_only_mode_ever_enabled" = true;

        # Downloads
        "browser.download.useDownloadDir" = true;
        "browser.download.always_ask_before_handling_new_types" = true;
        "browser.download.manager.addToRecentDocs" = false;

        # Performance
        "gfx.webrender.all" = true; # Enable WebRender if available
        "layers.acceleration.force-enabled" = true;
        "media.hardware-video-decoding.enabled" = true;
        "browser.cache.disk.enable" = true;
        "browser.cache.memory.enable" = true;
        "browser.cache.offline.enable" = true;

        # UI & Appearance
        "browser.compactmode.show" = true;
        "browser.uidensity" = 1; # 0=normal, 1=compact, 2=touch
        "browser.tabs.tabmanager.enabled" = false;
        "browser.fullscreen.autohide" = true;
        "full-screen-api.ignore-widgets" = true;

        # Developer Tools
        "devtools.chrome.enabled" = true;
        "devtools.debugger.remote-enabled" = false; # Disable remote debugging for security

        # Extensions
        "extensions.autoDisableScopes" = 0; # Allow all extension scopes
        "extensions.screenshots.disabled" = false;

        # PDF Viewer
        "pdfjs.disabled" = false;
        "pdfjs.enableWebGL" = true;

        # Miscellaneous
        "browser.aboutConfig.showWarning" = false; # Allow access to about:config without warning
        "browser.sessionstore.resume_from_crash" = true;
        "browser.sessionstore.max_tabs_undo" = 10;
        "browser.sessionstore.max_windows_undo" = 3;
        "browser.sessionstore.restore_on_demand" = false;
        "browser.sessionstore.restore_tabs_lazily" = false;
        "media.autoplay.default" = 5; # 0=allow, 1=block, 5=block all
        "media.autoplay.allow-muted" = false;
        "media.block-autoplay-until-in-user-activation" = true;
      };
      description = "Firefox preferences to set.";
    };

    extraPrefs = mkOption {
      type = types.lines;
      default = ''
        // Reduce link prefetching
        user_pref("network.dns.disablePrefetch", true);
        user_pref("network.prefetch-next", false);
        user_pref("network.predictor.enabled", false);
        user_pref("network.predictor.enable-prefetch", false);
        
        // Disable pocket
        user_pref("extensions.pocket.enabled", false);
        
        // Disable form autofill
        user_pref("extensions.formautofill.addresses.enabled", false);
        user_pref("extensions.formautofill.creditCards.enabled", false);
      '';
      description = "Extra preferences to add to user.js (fingerprint resistance and WebRTC are controlled by privacy options).";
    };

    extensions = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "List of Firefox extensions to install.";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages to install alongside Firefox.";
    };
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = cfg.package;
      profiles.default.settings = cfg.preferences // {
        # Search Engine
        "browser.search.defaultenginename" = cfg.search.defaultEngine;
        "browser.search.selectedEngine" = cfg.search.defaultEngine;
        "browser.search.suggest.enabled" = cfg.search.suggestions.enabled;
        "browser.urlbar.suggest.searches" = cfg.search.suggestions.urlbar;

        # Privacy & Tracking Protection
        "privacy.trackingprotection.enabled" = cfg.privacy.trackingProtection;
        "privacy.trackingprotection.socialtracking.enabled" = cfg.privacy.trackingProtection;
        "privacy.trackingprotection.cryptomining.enabled" = cfg.privacy.trackingProtection;
        "privacy.trackingprotection.fingerprinting.enabled" = cfg.privacy.trackingProtection;

        # Cookies
        "network.cookie.cookieBehavior" = cfg.privacy.cookieBehavior;

        # HTTPS-only mode
        "dom.security.https_only_mode" = cfg.privacy.httpsOnlyMode;
        "dom.security.https_only_mode_ever_enabled" = cfg.privacy.httpsOnlyMode;

        # Telemetry
        "toolkit.telemetry.enabled" = cfg.telemetry.enabled;
        "datareporting.policy.dataSubmissionEnabled" = cfg.telemetry.enabled;

        # Performance
        "gfx.webrender.all" = cfg.performance.webRender;
        "layers.acceleration.force-enabled" = cfg.performance.hardwareAcceleration;
      };
      profiles.default.extraConfig = 
        cfg.extraPrefs
        + (if cfg.privacy.resistFingerprinting then ''
          // Fingerprint resistance
          user_pref("privacy.resistFingerprinting", true);
          user_pref("privacy.resistFingerprinting.randomization.enabled", true);
          user_pref("privacy.resistFingerprinting.randomization.daily", true);
          user_pref("privacy.resistFingerprinting.letterboxing", true);
          user_pref("privacy.resistFingerprinting.pbmode", true);
        '' else "")
        + lib.optionalString (!cfg.privacy.webRTC) ''
          // Disable WebRTC leak
          user_pref("media.peerconnection.enabled", ''${"false"});
          user_pref("media.peerconnection.ice.default_address_only", true);
        '';
    };

    home.packages = cfg.extraPackages ++ cfg.extensions;
  };
}


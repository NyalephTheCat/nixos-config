{ config, pkgs, inputs, lib, ... }:
with lib;
let cfg = config.modules.firefox;
in
{
  options.modules.firefox = {
    enable = mkOption {
      default = true;
      example = true;
      description = "Whether to enable firefox.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;

      profiles.chloe = {
        settings = {};
        userChrome = ''
          * {
            box-shadow: none !important;
            border: 0px solid !important;
          }

          #tabbrowser-tabs {
            --user-tab-rounding: 8px;
          }

          .tab-background {
            border-radius: var(--user-tab-rounding) var(--user-tab-rounding) 0px 0px !important;
            margin-block: 1px 0 !important;
          }

          #scrollbutton-up, #scrollbutton-down {
            border-top-width: 1px !important;
          }

          [brighttext='true'] .tab-background:is([selected], [multiselected]):-moz-lwtheme {
            --lwt-tabs-border-color: rgba(255, 255, 255, 0.5) !important;
            border-bottom-color: transparent !important;
          }

          .tabbrowser-tab[usercontextid] > .tab-stack > .tab-background > .tab-context-line {
            margin: 0px max(calc(var(--user-tab-rounding) - 3px), 0px) !important;
            margin-block: 1px 0 !important;
          }

          #TabsToolbar, #tabbrowser-tabs {
            --tab-min-height: 29px !important;
          }
        ''; # TODO create own userChrome
      };
    };
  };
}

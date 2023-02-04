{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.bat;
in {
    options.modules.bat = { enable = mkEnableOption "zsh"; };

    config = mkIf cfg.enable {
        home.packages = [
            pkgs.bat
        ];

        programs.bat = {
            enable = true;
            extraPackages = with pkgs.bat-extras; [ batdiff batman batgrep batwatch ];
        };
    };
}

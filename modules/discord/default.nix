{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.discord;
in
{
  options.modules.discord = {
    enable = mkOption {
      default = true;
      example = true;
      description = "Whether to enable discord.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.discord ];
  };
}

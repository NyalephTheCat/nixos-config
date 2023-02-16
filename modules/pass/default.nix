{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.pass;
in
{
  options.modules.pass = {
    enable = mkOption {
      default = true;
      example = true;
      description = "Whether to enable password manager.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.pass.withExtensions (ext: with pkgs.passExtensions; [
        pass-otp
        pass-import
        pass-genphrase
        pass-audit
        pass-tomb
        pass-update
        pass-otp
      ]))
    ];
  };
}

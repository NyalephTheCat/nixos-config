{ pkgs, lib, config, ... }:
with lib;
let hasRust = builtins.elem "rust" config.language-support;
in
{
  config = mkIf hasRust {
    home.packages = [ pkgs.cargo ];
  };
}

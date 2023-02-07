{ inputs, pkgs, config, lib, ... }:
with lib;
{
  options.language-support = mkOption {
    default = [
      "bash"
      "c"
      "nix"
      "python"
      "rust"
      "tex"
    ];
    type = lib.types.listOf (types.enum [
      "bash"
      "c"
      "nix"
      "python"
      "rust"
      "tex"
    ]);
    description = ''
      Which languages to install additionnal support for.
    '';
  }; 
}

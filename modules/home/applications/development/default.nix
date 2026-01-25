{ config, pkgs, lib, ... }:

with lib;

{
  imports = [
    ./simple.nix
    ./vscode.nix
    ./cursor.nix
  ];
}


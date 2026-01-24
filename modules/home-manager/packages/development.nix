{ config, pkgs, lib, ... }:

{
  # User packages - development tools
  home.packages = with pkgs; [
    # Add development tools here
    # code-cursor # Add per-user if needed
    # IDEs and editors go here
  ];
}


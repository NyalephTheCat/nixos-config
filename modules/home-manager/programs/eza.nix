{ config, pkgs, lib, ... }:

{
  # Eza configuration (better ls)
  # Note: enableAliases is deprecated, aliases are enabled by default via shell integration
  # Note: icons should be a string ("auto", "always", "never") not a boolean
  programs.eza = {
    enable = true;
    git = true;
    icons = "auto";  # Changed from true to "auto" (deprecated boolean format)
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };
}


{ config, pkgs, lib, ... }:

{
  # User-specific editor packages
  home.packages = with pkgs; [
    # AI-powered editor
    code-cursor
    
    # VS Code
    vscode
    
    # Vim (configuration is in programs/vim.nix)
    vim
  ];
}


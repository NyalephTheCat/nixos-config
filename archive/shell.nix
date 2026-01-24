# Development shell for working on this NixOS configuration
# Usage: nix-shell (or `direnv allow` if using direnv)
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    # Nix tooling
    nixpkgs-fmt # Format Nix code
    nix-diff # Compare Nix derivations
    nix-tree # Visualize dependency tree
    
    # Git tools
    git
    gitAndTools.gitflow
    
    # Documentation
    man-pages
    man-pages-posix
    
    # Utilities
    jq
    yq
    ripgrep
    fd
    bat
  ];

  shellHook = ''
    echo "🔧 NixOS Configuration Development Shell"
    echo ""
    echo "Available commands:"
    echo "  nixpkgs-fmt    - Format Nix files"
    echo "  nix-diff       - Compare Nix derivations"
    echo "  nix-tree       - Visualize dependency tree"
    echo ""
    echo "To format all Nix files:"
    echo "  find . -name '*.nix' -exec nixpkgs-fmt {} +"
    echo ""
  '';
}


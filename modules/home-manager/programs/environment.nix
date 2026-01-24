{ config, pkgs, lib, ... }:

{
  # Environment variables
  home.sessionVariables = {
    # Editor
    EDITOR = "vim";
    VISUAL = "vim";
    
    # Pager
    PAGER = "less";
    MANPAGER = "less -R";
    
    # Language
    LANG = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    
    # Note: XDG directories are handled by the xdg module below, not here
    # to avoid conflicts with Home Manager's xdg module
    
    # Development
    CARGO_HOME = "$HOME/.cargo";
    RUSTUP_HOME = "$HOME/.rustup";
    GOPATH = "$HOME/go";
    GOBIN = "$HOME/go/bin";
    
    # Nix
    # Note: NIX_PATH is not needed in flakes (nixpkgs is available via flake inputs)
    # Removed to avoid pure evaluation mode issues with <nixpkgs>
    # If you need NIX_PATH for legacy tools, set it manually or use: NIX_PATH = "nixpkgs=${toString pkgs.path}";
  };

  # XDG directory configuration
  xdg = {
    enable = true;
    
    configFile = lib.mkDefault {};
    dataFile = lib.mkDefault {};
    cacheFile = lib.mkDefault {};
    stateFile = lib.mkDefault {};
    
    # User directories
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      publicShare = "$HOME/Public";
      templates = "$HOME/Templates";
      videos = "$HOME/Videos";
    };
  };
}


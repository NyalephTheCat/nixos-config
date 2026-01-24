{ config, pkgs, ... }:

{
  # Basic Home Manager settings
  home.username = "nyaleph";
  home.homeDirectory = "/home/nyaleph";
  home.stateVersion = "25.11";

  # User-specific packages
  # Note: System-wide packages are defined in modules/packages/packages.nix
  # Note: direnv is configured via programs.direnv below, no need to add it here
  home.packages = with pkgs; [
    discord
    vesktop
    code-cursor
    vlc
    # Terminal utilities
    starship # Cross-shell prompt (also configured via programs.starship below)
    qbittorrent
    r2modman
    # Development tools
    gcc
    gnumake
    cmake
    pkg-config
    openssl
    alsa-lib # ALSA development library (needed for Rust crates like alsa-sys)
    systemd # Systemd development library (needed for Rust crates like libudev-sys)
    nodejs_22
    python3
    python3Packages.pip
    texlive.combined.scheme-full # Full LaTeX distribution (large package)
    # Rust toolchain (using rustup - rustc and cargo are already system-wide)
    # Note: If you prefer rustup-managed toolchain, remove rustc/cargo from system packages
    rustup
    # Utilities
    jq
    curl
    wget
    ripgrep
    fd
    bat
    eza
    fzf
  ];

  # Programs configuration
  programs.home-manager.enable = true;

  # Git configuration
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "nyaleph";
        email = "chloe@magnier.dev";
      };
      init.defaultBranch = "main";
      pull.rebase = false;
      core.editor = "vim";
      color.ui = true;
      alias = {
        st = "status";
        co = "checkout";
        br = "branch";
        ci = "commit";
        cp = "cherry-pick";
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        visual = "!gitk";
      };
    };
  };

  # Starship prompt (cross-shell prompt)
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = true;
      format = "$all$character";
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };

  # Terminal configuration
  programs.kitty = {
    enable = true;
    settings = {
      font_family = "Fira Code";
      font_size = 12;
      background_opacity = "0.95";
      enable_audio_bell = false;
      window_padding_width = 5;
      confirm_os_window_close = 0;
    };
  };

  # Alacritty (alternative terminal, uncomment if preferred)
  # programs.alacritty = {
  #   enable = true;
  #   settings = {
  #     font = {
  #       normal = {
  #         family = "Fira Code";
  #         style = "Regular";
  #       };
  #       size = 12;
  #     };
  #     window = {
  #       opacity = 0.95;
  #       padding = { x = 5; y = 5; };
  #     };
  #   };
  # };

  # Neovim configuration (if you use Neovim)
  # programs.neovim = {
  #   enable = true;
  #   viAlias = true;
  #   vimAlias = true;
  #   defaultEditor = true;
  # };

  # Direnv configuration
  # Direnv automatically loads/unloads environment variables based on .envrc files
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true; # Faster direnv with nix integration
    # Optional: configure direnv to use nix-direnv cache
    config = {
      global = {
        warn_timeout = "5s";
      };
    };
  };
}

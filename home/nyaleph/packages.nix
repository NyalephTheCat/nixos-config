{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Development
    git
    neovim
    vscode
    direnv

    # Terminal utilities
    ripgrep
    fd
    eza
    bat
    fzf
    zoxide
    htop
    btop

    # System tools
    firefox
    thunderbird
    libreoffice
    vlc

    # KDE/Plasma specific
    kdePackages.kate
    kdePackages.kdeconnect-kde
    kdePackages.yakuake

    # Communication
    discord
    signal-desktop

    # Media
    spotify
    gimp
    inkscape

    # Archives
    unzip
    p7zip
    unrar
  ];
}

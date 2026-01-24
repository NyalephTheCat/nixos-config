{ config, pkgs, lib, ... }:

{
  # Fonts - system-wide fonts
  environment.systemPackages = with pkgs; lib.mkDefault [
    # Basic fonts
    dejavu_fonts
    noto-fonts
    liberation_ttf
    
    # Code fonts
    fira-code
    fira-code-symbols
    jetbrains-mono
    source-code-pro
    
    # Nerd Fonts (includes icon fonts)
    # Note: Package name may vary - try 'nerdfonts' or 'nerd-fonts' if this doesn't work
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" "SourceCodePro" ]; })
    
    # UI fonts
    inter
    roboto
    open-sans
    
    # Monospace alternatives
    hack-font
    iosevka
    cascadia-code
  ];
  
  # Enable fontconfig for better font rendering
  fonts = {
    enableDefaultPackages = true;
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "FiraCode Nerd Font" "Fira Code" "DejaVu Sans Mono" ];
        sansSerif = [ "Inter" "Roboto" "DejaVu Sans" ];
        serif = [ "DejaVu Serif" "Liberation Serif" ];
      };
    };
  };
}


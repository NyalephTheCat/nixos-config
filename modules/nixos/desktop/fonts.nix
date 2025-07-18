{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.desktop.fonts;
in
{
  options.modules.desktop.fonts = {
    enable = mkEnableOption "font configuration";
    
    packages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-emoji
        liberation_ttf
      ];
      description = "Base font packages to install";
    };
    
    monospace = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        fira-code
        fira-code-symbols
        jetbrains-mono
        source-code-pro
        nerd-fonts.jetbrains-mono
        nerd-fonts.fira-code
      ];
      description = "Monospace font packages";
    };
    
    defaults = {
      serif = mkOption {
        type = types.listOf types.str;
        default = [ "Noto Serif" ];
        description = "Default serif fonts";
      };
      
      sansSerif = mkOption {
        type = types.listOf types.str;
        default = [ "Noto Sans" ];
        description = "Default sans-serif fonts";
      };
      
      monospace = mkOption {
        type = types.listOf types.str;
        default = [ "JetBrains Mono" "Fira Code" ];
        description = "Default monospace fonts";
      };
      
      emoji = mkOption {
        type = types.listOf types.str;
        default = [ "Noto Color Emoji" ];
        description = "Default emoji fonts";
      };
    };
    
    subpixel = {
      rgba = mkOption {
        type = types.enum [ "none" "rgb" "bgr" "vrgb" "vbgr" ];
        default = "rgb";
        description = "Subpixel rendering order";
      };
      
      lcdfilter = mkOption {
        type = types.enum [ "none" "default" "light" "legacy" ];
        default = "default";
        description = "LCD filter type";
      };
    };
    
    hinting = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable font hinting";
      };
      
      style = mkOption {
        type = types.enum [ "none" "slight" "medium" "full" ];
        default = "slight";
        description = "Font hinting style";
      };
      
      autohint = mkOption {
        type = types.bool;
        default = true;
        description = "Enable autohinting";
      };
    };
  };

  config = mkIf cfg.enable {
    fonts = {
      packages = cfg.packages ++ cfg.monospace;
      
      fontconfig = {
        enable = true;
        
        defaultFonts = {
          serif = cfg.defaults.serif;
          sansSerif = cfg.defaults.sansSerif;
          monospace = cfg.defaults.monospace;
          emoji = cfg.defaults.emoji;
        };
        
        subpixel = {
          rgba = cfg.subpixel.rgba;
          lcdfilter = cfg.subpixel.lcdfilter;
        };
        
        hinting = {
          enable = cfg.hinting.enable;
          style = cfg.hinting.style;
          autohint = cfg.hinting.autohint;
        };
        
        # Additional fontconfig rules
        localConf = ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
          <fontconfig>
            <!-- Disable bitmap fonts -->
            <match target="font">
              <edit name="embeddedbitmap" mode="assign">
                <bool>false</bool>
              </edit>
            </match>
            
            <!-- Set DPI -->
            <match target="pattern">
              <edit name="dpi" mode="assign">
                <double>96</double>
              </edit>
            </match>
            
            <!-- Better rendering for specific fonts -->
            <match target="font">
              <test name="family" compare="contains">
                <string>Noto</string>
              </test>
              <edit name="hinting" mode="assign">
                <bool>true</bool>
              </edit>
              <edit name="hintstyle" mode="assign">
                <const>hintslight</const>
              </edit>
            </match>
          </fontconfig>
        '';
      };
    };
    
    # Font tools
    environment.systemPackages = with pkgs; [
      fontconfig
      font-manager
    ];
  };
}
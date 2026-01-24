{ config, pkgs, lib, ... }:

{
  # Time zone - can be overridden per host
  time.timeZone = lib.mkDefault "Europe/Paris";

  # Internationalisation
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  
  # Supported locales (can be extended per-host)
  i18n.supportedLocales = lib.mkDefault [
    "en_US.UTF-8/UTF-8"
    "en_GB.UTF-8/UTF-8"
    "fr_FR.UTF-8/UTF-8"
  ];
  
  i18n.extraLocaleSettings = {
    LC_ADDRESS = lib.mkDefault "en_US.UTF-8";
    LC_IDENTIFICATION = lib.mkDefault "en_US.UTF-8";
    LC_MEASUREMENT = lib.mkDefault "en_US.UTF-8";
    LC_MONETARY = lib.mkDefault "en_US.UTF-8";
    LC_NAME = lib.mkDefault "en_US.UTF-8";
    LC_NUMERIC = lib.mkDefault "en_US.UTF-8";
    LC_PAPER = lib.mkDefault "en_US.UTF-8";
    LC_TELEPHONE = lib.mkDefault "en_US.UTF-8";
    LC_TIME = lib.mkDefault "en_US.UTF-8";
  };
}


{ config, pkgs, lib, ... }:

{
  # Feature flags for heaven host
  # See FEATURES.md for complete reference
  features = {
    # Gaming optimizations and software
    gaming = {
      enable = true;
    };
    
    # Virtualization platforms
    virtualization = {
      docker = true;
      libvirt = true;
    };
    
    # Development tools and compilers
    development = {
      enable = true;
    };
    
    # Desktop environment
    desktop = {
      environment = "plasma";
    };
    
    # Hardware-specific settings
    hardware = {
      gpu = "amd";
      type = "desktop";
    };
    
    # Printing services
    printing = {
      enable = true;
    };
  };
}


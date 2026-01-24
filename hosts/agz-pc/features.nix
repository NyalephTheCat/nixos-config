{ config, pkgs, lib, ... }:

{
  # Feature flags for agz-pc host
  # Customize these based on agz's preferences and hardware
  # See FEATURES.md for complete reference
  features = {
    # Gaming optimizations and software
    gaming = {
      enable = true;  # Set to true if gaming is desired
    };
    
    # Virtualization platforms
    virtualization = {
      docker = true;   # Set to true if Docker is needed (adds user to docker group)
      libvirt = true; # Set to true if VMs are needed (adds user to libvirtd group)
    };
    
    # Development tools and compilers
    development = {
      enable = false;  # Set to true if development tools are needed
    };
    
    # Desktop environment
    desktop = {
      environment = "plasma";  # Options: "plasma", "gnome", "none"
    };
    
    # Hardware-specific settings
    hardware = {
      gpu = "amd";      # Change to "nvidia" or "intel" based on actual hardware
      type = "desktop"; # Change to "laptop" if it's a laptop
    };
    
    # Printing services
    printing = {
      enable = true;  # CUPS printing service
    };
  };
}


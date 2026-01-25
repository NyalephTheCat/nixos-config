# NixOS Configuration

A flake-based NixOS and Home Manager configuration for managing multiple hosts with a modular structure.

## Overview

This repository contains:
- **NixOS system configurations** for multiple hosts
- **Home Manager configurations** for user environments
- **Modular system and home modules** for easy customization
- **Pre-configured applications, emulators, and development tools**

### Current Hosts

- `heaven` - Main desktop system (Europe/Paris timezone, French locale)
- `agz-pc` - Secondary desktop system (America/Sao_Paulo timezone, Brazilian Portuguese locale)

## Prerequisites

Before you begin, ensure you have:

1. **NixOS installed** (or a NixOS installation medium)
2. **Nix Flakes enabled** - Flakes are required for this configuration
3. **Git** installed
4. **Root or sudo access** for system configuration

### Enabling Flakes (if not already enabled)

If you're on an existing NixOS system without flakes enabled:

```bash
# Add to /etc/nixos/configuration.nix
{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}

# Then rebuild
sudo nixos-rebuild switch
```

## Installation

### For a New NixOS Installation

1. **Boot from NixOS installation medium** (ISO or USB)

2. **Partition your disk** (if not already done):
   ```bash
   # Example using parted (adjust as needed)
   sudo parted /dev/sda -- mklabel gpt
   sudo parted /dev/sda -- mkpart primary 512MiB -8GiB
   sudo parted /dev/sda -- mkpart primary linux-swap -8GiB 100%
   sudo parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
   sudo parted /dev/sda -- set 3 esp on
   
   # Format partitions
   sudo mkfs.ext4 -L nixos /dev/sda1
   sudo mkswap -L swap /dev/sda2
   sudo mkfs.fat -F 32 -n boot /dev/sda3
   
   # Mount
   sudo mount /dev/disk/by-label/nixos /mnt
   sudo mkdir -p /mnt/boot
   sudo mount /dev/disk/by-label/boot /mnt/boot
   sudo swapon /dev/sda2
   ```

3. **Clone this repository**:
   ```bash
   sudo mkdir -p /mnt/etc/nixos
   cd /mnt/etc/nixos
   sudo git clone <your-repo-url> .
   ```

4. **Generate hardware configuration** (if needed):
   ```bash
   sudo nixos-generate-config --root /mnt --dir /mnt/etc/nixos/hosts/<hostname>
   ```
   
   Replace `<hostname>` with your desired hostname (e.g., `heaven` or `agz-pc`).

5. **Edit the hardware configuration**:
   - Update `hosts/<hostname>/hardware.nix` with your disk UUIDs and hardware-specific settings
   - Review `hosts/<hostname>/default.nix` and adjust:
     - Hostname
     - Timezone
     - Locale settings
     - Keyboard layout
     - User configuration

6. **Install NixOS**:
   ```bash
   sudo nixos-install --flake /mnt/etc/nixos#<hostname>
   ```
   
   Replace `<hostname>` with your hostname (e.g., `heaven` or `agz-pc`).

7. **Set root password** when prompted

8. **Reboot**:
   ```bash
   sudo reboot
   ```

### For an Existing NixOS System

1. **Clone this repository**:
   ```bash
   cd ~/.config
   git clone <your-repo-url> nixos
   cd nixos
   ```

2. **Create or update your host configuration**:
   - Copy an existing host from `hosts/` as a template
   - Update `hosts/<hostname>/default.nix` with your settings
   - Generate hardware config if needed: `sudo nixos-generate-config --dir hosts/<hostname>`

3. **Add your host to flake.nix**:
   ```nix
   nixosConfigurations = {
     heaven = mkHost "heaven";
     agz-pc = mkHost "agz-pc";
     your-hostname = mkHost "your-hostname";  # Add your host here
   };
   ```

4. **Build and switch**:
   ```bash
   sudo nixos-rebuild switch --flake .#<hostname>
   ```

## Configuration Structure

```
.
├── flake.nix              # Main flake configuration
├── hosts/                 # Host-specific configurations
│   ├── heaven/
│   │   ├── default.nix    # System configuration
│   │   └── hardware.nix   # Hardware-specific settings
│   └── agz-pc/
│       ├── default.nix
│       └── hardware.nix
├── home/                  # Home Manager configurations
│   ├── default.nix        # Base home configuration
│   └── users/             # User-specific configs
│       ├── nyaleph.nix
│       └── agz-cadentis.nix
├── modules/               # Reusable modules
│   ├── system/           # System-level modules
│   │   ├── plasma6.nix   # Plasma6 desktop
│   │   ├── amd-drivers.nix
│   │   └── basic-apps.nix
│   └── home/             # Home Manager modules
│       ├── applications/ # Application configurations
│       ├── emulators/    # Emulator configurations
│       ├── terminal/     # Terminal configurations
│       └── programs/     # Program configurations
└── lib/                  # Utility functions
    └── utils.nix
```

## Customization

### Adding a New Host

1. **Create host directory**:
   ```bash
   mkdir -p hosts/your-hostname
   ```

2. **Create default.nix** (use an existing host as template):
   ```nix
   { config, pkgs, lib, home-manager, customUtils, ... }:
   
   {
     imports = [
       ./hardware.nix
       ../../modules/system/plasma6.nix
       # Add other modules as needed
     ];
   
     system.stateVersion = "25.11";
     networking.hostName = "your-hostname";
     time.timeZone = "Your/Timezone";
     # ... other configuration
   }
   ```

3. **Generate hardware configuration**:
   ```bash
   sudo nixos-generate-config --dir hosts/your-hostname
   ```

4. **Add to flake.nix**:
   ```nix
   nixosConfigurations = {
     # ... existing hosts
     your-hostname = mkHost "your-hostname";
   };
   ```

5. **Create user configuration** in `home/users/your-username.nix` if needed

### Enabling Applications

Edit your user's home configuration (e.g., `home/users/nyaleph.nix`):

```nix
applications = {
  firefox.enable = true;
  steam.enable = true;
  cursor.enable = true;
  # ... other applications
};
```

Available application modules are in `modules/home/applications/`.

### Enabling Emulators

In your user configuration:

```nix
emulators = {
  enable = true;
  retroarch.enable = true;
  dolphin.enable = true;
  # ... other emulators
};
```

### Configuring Git

In your user configuration:

```nix
tools.git = {
  enable = true;
  userName = "Your Name";
  userEmail = "your.email@example.com";
};
```

## Building and Switching

### Build Configuration

```bash
# Build for a specific host
sudo nixos-rebuild build --flake .#<hostname>

# Test build (dry-run)
sudo nixos-rebuild build --flake .#<hostname> --dry-run
```

### Switch to New Configuration

```bash
# Switch immediately
sudo nixos-rebuild switch --flake .#<hostname>

# Switch and update flake inputs
sudo nixos-rebuild switch --flake .#<hostname --update-input nixpkgs
```

### Boot from Previous Generation

If something goes wrong, you can boot from a previous generation:

1. **At boot menu**: Select an older generation
2. **Or rollback from current system**:
   ```bash
   sudo nixos-rebuild switch --flake .#<hostname> --rollback
   ```

## Updating

### Update Flake Inputs

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake update nixpkgs

# Update and rebuild
sudo nixos-rebuild switch --flake .#<hostname> --update-input nixpkgs
```

### Garbage Collection

Automatic garbage collection is configured, but you can run manually:

```bash
# Collect garbage
nix-collect-garbage -d

# Remove old generations
sudo nix-collect-garbage -d
```

## Troubleshooting

### Build Fails

1. **Check for syntax errors**:
   ```bash
   nix flake check
   ```

2. **Check evaluation**:
   ```bash
   nix eval .#nixosConfigurations.<hostname>.config.system.build.toplevel
   ```

3. **Review error messages** - Nix error messages usually point to the issue

### Module Not Found

- Ensure the module path is correct in your imports
- Check that the module file exists
- Verify the module exports the correct options

### Home Manager Issues

- Ensure the user exists in the system configuration
- Check that `home-manager.users.<username>` is properly configured
- Verify Home Manager is imported in the system configuration

### Hardware Issues

- Regenerate hardware configuration: `sudo nixos-generate-config --dir hosts/<hostname>`
- Update `hardware.nix` with correct disk UUIDs
- Check hardware-specific modules (e.g., `amd-drivers.nix` for AMD GPUs)

## Features

### System Features

- **Plasma6 Desktop Environment** - Modern KDE desktop
- **PipeWire Audio** - Modern audio server with JACK and PulseAudio support
- **Bluetooth Support** - With Blueman manager
- **AMD GPU Drivers** - Automatic configuration for AMD graphics
- **Automatic Garbage Collection** - Weekly cleanup of old packages

### Home Manager Features

- **Application Management** - Easy enable/disable of applications
- **Emulator Support** - RetroArch, Dolphin, PCSX2, RPCS3, and more
- **Terminal Configuration** - Kitty terminal and Zsh shell
- **Git Configuration** - Per-user Git settings
- **Development Tools** - Cursor, VSCode, and more

## Contributing

When making changes:

1. Test builds before switching: `sudo nixos-rebuild build --flake .#<hostname>`
2. Keep hardware configurations separate from system configs
3. Use modules for reusable configurations
4. Document any new modules or significant changes

## License

[Add your license here]

## Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [NixOS Wiki](https://nixos.wiki/)

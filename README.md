# Multi-Host NixOS Configuration

A modular NixOS configuration supporting multiple hosts and users with shared modules and feature flags.

## 🚀 Setup

### Cloning the Repository

1. **Clone the repository:**
   ```bash
   # If using Git
   git clone <repository-url> ~/.config/nixos
   cd ~/.config/nixos
   ```

### Initial Setup

1. **Navigate to the configuration directory:**
   ```bash
   cd ~/.config/nixos
   ```

2. **Validate the configuration:**
   ```bash
   nix flake check
   ```

3. **Deploy to your host:**
   ```bash
   # For heaven (nyaleph's system)
   sudo nixos-rebuild switch --flake .#heaven
   
   # For agz-pc (agz's system)
   sudo nixos-rebuild switch --flake .#agz-pc
   ```

### First-Time Setup for a New Host

1. **Generate hardware configuration:**
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/new-hostname/hardware-configuration.nix
   ```

2. **Create host configuration files:**
   - Copy `hosts/heaven/configuration.nix` to `hosts/new-hostname/configuration.nix` and customize
   - Create `hosts/new-hostname/features.nix` with your feature flags

3. **Add to `flake.nix`:**
   ```nix
   nixosConfigurations = {
     new-hostname = mkHost "new-hostname" {
       system = "x86_64-linux";
       users = [ "username" ];
     };
   };
   ```

4. **Deploy:**
   ```bash
   sudo nixos-rebuild switch --flake .#new-hostname
   ```

## ⚙️ Customization

### Enable/Disable Features

Edit `hosts/<hostname>/features.nix`:

```nix
{
  features = {
    gaming.enable = true;           # Gaming optimizations
    virtualization.docker = true;   # Docker support
    virtualization.libvirt = true;  # VM support (QEMU/KVM)
    development.enable = true;      # Development tools
    desktop.environment = "plasma"; # "plasma" or "gnome"
    hardware.gpu = "amd";           # "amd", "nvidia", or "intel"
    hardware.type = "desktop";      # "desktop" or "laptop"
    printing.enable = true;         # Printing services
  };
}
```

### User Features

Edit `users/<username>/home.nix`:

```nix
{
  features.user = {
    gaming-tools = true;      # Discord, game launchers
    content-creation = false; # GIMP, Inkscape, video editors
    streaming = false;        # OBS, streaming tools
    development = true;       # Full dev environment
  };
}
```

### Add Packages

**System-wide:** Edit `modules/nixos/packages/default.nix`

**User-specific:** Edit `users/<username>/packages.nix`

### Configure Git

Edit `users/<username>/home.nix`:

```nix
{
  programs.git.settings = {
    user.name = "Your Name";
    user.email = "your@email.com";
  };
}
```

## 📁 Directory Structure

```
.
├── flake.nix                      # Multi-host flake configuration
├── hosts/                         # Per-host configurations
│   ├── heaven/                   # nyaleph's system
│   └── agz-pc/                   # agz's system
├── users/                         # Per-user configurations
│   ├── nyaleph/
│   └── agz-cadentis/
├── modules/
│   ├── nixos/                    # Shared NixOS modules
│   └── home-manager/             # Shared Home Manager modules
├── lib/                          # Helper functions
└── shared/                       # Shared resources (fonts, themes, etc.)
```

## 🔄 Maintenance

### Update System

```bash
# Update flake inputs
nix flake update

# Rebuild and switch
sudo nixos-rebuild switch --flake .#heaven
```

### Rollback

```bash
# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Or select from GRUB menu at boot
```

### Garbage Collection

```bash
# Remove old generations
sudo nix-collect-garbage -d
```

## 🐛 Troubleshooting

### Build Errors

```bash
# Show detailed error messages
sudo nixos-rebuild switch --flake .#heaven --show-trace

# Check configuration validity
nix flake check
```

### Common Issues

- **Module not found:** Check imports in configuration files
- **Option doesn't exist:** Verify feature flags are properly set
- **Build fails:** Run with `--show-trace` for detailed errors

## 📚 Available Features

### System Features
- **Gaming:** Gamemode, Steam, Lutris
- **Virtualization:** Docker, libvirt/QEMU
- **Development:** Compilers, build tools, language toolchains
- **Desktop:** KDE Plasma 6, GNOME
- **Printing:** CUPS printing services

### User Features
- **Gaming Tools:** Discord, Vesktop, game mod managers
- **Content Creation:** GIMP, Inkscape, Krita, Blender
- **Streaming:** OBS and streaming tools
- **Development:** IDEs, language-specific tools

## 🎯 Quick Reference

```bash
# Deploy configuration
sudo nixos-rebuild switch --flake .#heaven

# Test build without switching
sudo nixos-rebuild dry-build --flake .#heaven

# Update inputs
nix flake update

# Validate configuration
nix flake check

# List system generations
sudo nix-env --list-generations -p /nix/var/nix/profiles/system
```

## 📝 Additional Documentation

- **QUICKSTART.md** - Quick start guide with step-by-step instructions
- **FEATURES.md** - Complete feature flags reference
- **DECISIONS.md** - Architecture and design decisions

---

**Tip:** Always run `nix flake check` before deploying to catch errors early!

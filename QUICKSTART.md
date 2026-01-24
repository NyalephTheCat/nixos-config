# Quick Start Guide

Get started with your new multi-host NixOS configuration in minutes!

## 🚀 Deploy to heaven (Your Current System)

### Option 1: Careful Migration (Recommended)

```bash
cd /home/nyaleph/.config/nixos

# 1. Validate everything is ready
nix flake check

# 2. Test without committing
sudo nixos-rebuild test --flake .#heaven

# 3. If everything works, make it permanent
sudo nixos-rebuild switch --flake .#heaven
```

### Option 2: Quick Deploy (If Confident)

```bash
cd /home/nyaleph/.config/nixos
sudo nixos-rebuild switch --flake .#heaven
```

## 🔄 Regular Updates

```bash
cd /home/nyaleph/.config/nixos

# Update all inputs
nix flake update

# Deploy
sudo nixos-rebuild switch --flake .#heaven
```

## ⚙️ Customize Your System

### Enable/Disable Features

Edit `hosts/heaven/features.nix`:

```nix
{
  features = {
    gaming.enable = true;           # Toggle gaming
    virtualization.docker = true;   # Toggle Docker
    virtualization.libvirt = true;  # Toggle VMs
    development.enable = true;      # Toggle dev tools
    desktop.environment = "plasma"; # plasma or gnome
    hardware.gpu = "amd";           # amd, nvidia, intel
    printing.enable = true;         # Toggle printing
  };
}
```

### Add User Packages

Edit `users/nyaleph/packages.nix`:

```nix
{
  home.packages = with pkgs; [
    # Add your packages here
    firefox
    vscode
    # etc...
  ];
}
```

### Change Git Config

Edit `users/nyaleph/home.nix`:

```nix
{
  programs.git.userName = "Your Name";
  programs.git.userEmail = "your@email.com";
}
```

## 🖥️ Set Up agz-pc Later

When ready to set up agz's computer:

```bash
# 1. On agz's system, generate hardware config
sudo nixos-generate-config --show-hardware-config > /tmp/hardware-config.nix

# 2. Copy to your config repo
cp /tmp/hardware-config.nix /path/to/nixos/hosts/agz-pc/hardware-configuration.nix

# 3. Customize features in hosts/agz-pc/features.nix

# 4. Update user settings in users/agz-cadentis/home.nix

# 5. Deploy
sudo nixos-rebuild switch --flake .#agz-pc
# Or: sudo nixos-rebuild switch --flake .#agz-pc
```

## 🆘 Troubleshooting

### Build Errors

```bash
# Show detailed errors
sudo nixos-rebuild switch --flake .#heaven --show-trace

# Check configuration
nix flake check
```

### Rollback

```bash
# Rollback to previous generation
sudo nixos-rebuild switch --rollback

# Or select from GRUB menu at boot
```

### Validation

```bash
# Check everything is correct
nix flake check

# Check configs build
nix build .#heaven --dry-run
```

## 📚 Documentation

- **README.md** - Full documentation
- **MIGRATION.md** - Detailed migration steps
- **DECISIONS.md** - Why things are structured this way
- **FEATURES.md** - Feature flags reference

## ✅ Quick Checklist

Before deploying:
- [ ] Ran `nix flake check` ✓
- [ ] Reviewed `hosts/heaven/features.nix`
- [ ] Checked `users/nyaleph/home.nix` settings
- [ ] Understand rollback process

After deploying:
- [ ] System boots correctly
- [ ] Desktop environment works
- [ ] Applications launch
- [ ] Gaming/Virtualization works (if enabled)
- [ ] User environment correct

## 💡 Useful Commands

```bash
# Deploy to heaven
sudo nixos-rebuild switch --flake .#heaven

# Deploy to agz-pc
sudo nixos-rebuild switch --flake .#agz-pc

# Update all inputs
nix flake update

# Validate configuration
nix flake check

# Garbage collection
sudo nix-collect-garbage -d

# List generations
sudo nix-env --list-generations -p /nix/var/nix/profiles/system
```

## 🎯 Common Tasks

### Change Desktop Environment

Edit `hosts/heaven/features.nix`:
```nix
desktop.environment = "gnome"; # Switch to GNOME
```

### Enable Gaming

Edit `hosts/heaven/features.nix`:
```nix
gaming.enable = true;
```

### Add Custom Package

Edit `users/nyaleph/packages.nix`:
```nix
home.packages = with pkgs; [
  your-package-here
];
```

---

**That's it! You're ready to go! 🚀**

For more details, see README.md. For migration help, see MIGRATION.md.


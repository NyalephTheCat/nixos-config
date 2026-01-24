# Feature Flags Reference

Complete reference of all available feature flags for hosts and users.

## Host-Level Features

Configured in `hosts/<hostname>/features.nix`

### Gaming

```nix
features.gaming.enable = true;  # Enable gaming optimizations
```

**Enables:**
- Gamemode (performance optimization)
- MangoHud (performance overlay)
- Steam (gaming platform)
- Hytale launcher (via Flatpak)

### Virtualization

```nix
features.virtualization = {
  docker = true;    # Enable Docker containerization
  libvirt = true;   # Enable libvirt/QEMU for VMs
};
```

**Enables:**
- Docker daemon and CLI tools
- libvirt/QEMU virtualization
- User groups: `docker`, `libvirtd` (automatically added)
- Firewall rules for VNC (if libvirt enabled)

### Development

```nix
features.development.enable = true;  # Enable development tools
```

**Enables:**
- GCC, make, cmake, pkg-config
- Git
- Python, Node.js, Rust, Go toolchains
- Docker Compose
- Build utilities (automake, autoconf, etc.)
- Direnv system-wide

### Desktop Environment

```nix
features.desktop.environment = "plasma";  # "plasma" or "gnome"
```

**Options:**
- `"plasma"` - KDE Plasma 6
- `"gnome"` - GNOME Desktop
- `"none"` - No desktop environment

**Enables:**
- X11 windowing system
- Display manager (SDDM for Plasma, GDM for GNOME)
- Desktop environment
- Keyboard layout configuration

### Hardware

```nix
features.hardware = {
  gpu = "amd";      # "amd", "nvidia", "intel", or "none"
  type = "desktop"; # "desktop" or "laptop"
};
```

**GPU Options:**
- `"amd"` - AMD GPU optimizations
- `"nvidia"` - NVIDIA GPU (requires nvidia drivers)
- `"intel"` - Intel integrated graphics
- `"none"` - No GPU-specific optimizations

**Type Options:**
- `"desktop"` - Desktop system (performance governor)
- `"laptop"` - Laptop (may use powersave governor)

**Effects:**
- Gamemode GPU optimizations (if gaming enabled)
- Power management settings
- Future: Hardware-specific profiles

### Printing

```nix
features.printing.enable = true;  # Enable CUPS printing
```

**Enables:**
- CUPS printing service
- Avahi for printer discovery (optional)

## User-Level Features

Configured in `users/<username>/home.nix`

### Gaming Tools

```nix
features.user.gaming-tools = true;
```

**Installs:**
- Discord
- Vesktop
- r2modman
- Other gaming-related applications

### Content Creation

```nix
features.user.content-creation = true;
```

**Installs:**
- GIMP (image editing)
- Inkscape (vector graphics)
- Krita (digital painting)
- Blender (3D modeling)
- Kdenlive (video editing)

### Streaming

```nix
features.user.streaming = true;
```

**Installs:**
- OBS Studio
- Other streaming tools

### Development

```nix
features.user.development = true;
```

**Installs:**
- IDEs (VS Code, Cursor, etc.)
- Language-specific development tools
- Additional development utilities

## Feature Flag Examples

### Gaming Desktop (heaven)

```nix
{
  features = {
    gaming.enable = true;
    virtualization.docker = true;
    virtualization.libvirt = true;
    development.enable = true;
    desktop.environment = "plasma";
    hardware.gpu = "amd";
    hardware.type = "desktop";
    printing.enable = true;
  };
}
```

### Minimal Workstation (agz-pc)

```nix
{
  features = {
    gaming.enable = false;
    virtualization.docker = false;
    virtualization.libvirt = false;
    development.enable = false;
    desktop.environment = "plasma";
    hardware.gpu = "amd";
    hardware.type = "desktop";
    printing.enable = true;
  };
}
```

### Development Laptop

```nix
{
  features = {
    gaming.enable = false;
    virtualization.docker = true;
    virtualization.libvirt = false;
    development.enable = true;
    desktop.environment = "gnome";
    hardware.gpu = "intel";
    hardware.type = "laptop";
    printing.enable = false;
  };
}
```

## How Feature Flags Work

1. **Host features** are defined in `hosts/<hostname>/features.nix`
2. **User features** are defined in `users/<username>/home.nix`
3. Modules check flags using `lib.mkIf` for conditional loading
4. Defaults are provided if flags are missing
5. Flags can be overridden per-host or per-user

## Conditional Behavior

- **Gaming module:** Only loads if `features.gaming.enable = true`
- **Virtualization:** Only loads Docker/libvirt if respective flags are true
- **Desktop:** Only loads selected desktop environment
- **User groups:** Automatically added based on virtualization flags
- **Steam:** Only enabled if gaming is enabled

## Best Practices

1. **Set all flags explicitly** in features.nix (don't rely on defaults)
2. **Document custom flags** if you add new ones
3. **Test after changing flags** with `nixos-rebuild test`
4. **Use feature flags** instead of commenting out modules
5. **Keep flags organized** by category

## Adding New Feature Flags

1. Add flag to `hosts/<hostname>/features.nix` or `users/<username>/home.nix`
2. Check flag in module with `lib.mkIf`
3. Document in this file
4. Update examples if needed

## Feature Dependencies

Some features may depend on others:
- **Gaming** typically requires a **desktop environment** (for GUI games)
- **Virtualization** may benefit from **development** tools
- **Content creation** may require **desktop environment**

Use the library helpers to check dependencies:
```nix
# In a module
{ config, lib, ... }:
let
  customLib = import ../../lib/default.nix { inherit lib; };
in
{
  # Check if dependencies are met
  assertions = [
    {
      assertion = customLib.checkFeatureDependencies config {
        "features.gaming.enable" = [ "features.desktop.environment" ];
      };
      message = "Gaming feature requires a desktop environment";
    }
  ];
}
```

## Feature Presets

Pre-configured feature combinations are available via `lib.applyFeaturePreset`:

- **gaming-desktop**: Gaming optimizations with desktop environment
- **development-laptop**: Development tools optimized for laptops
- **minimal-server**: Minimal configuration for servers

Example:
```nix
# Apply a preset
config = lib.applyFeaturePreset config "gaming-desktop";
```

## Feature Conflicts

Some features may conflict with each other:
- **Server** mode may conflict with **gaming** (different use cases)
- Some hardware profiles may conflict (e.g., AMD vs NVIDIA)

Use `lib.detectFeatureConflicts` to check for conflicts:
```nix
let
  conflicts = lib.detectFeatureConflicts config {
    "features.gaming.enable" = [ "features.server.enable" ];
  };
in
# Handle conflicts
```

---

For more details, see the module source code in `modules/nixos/features/` and `modules/home-manager/features/`.


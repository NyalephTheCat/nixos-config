# NixOS Modules

This directory contains system-level NixOS modules that configure the entire system.

## Structure

- **core/** - Essential system configuration (boot, locale, networking, nix)
- **hardware/** - Hardware support (graphics, audio, bluetooth)
- **desktop/** - Desktop environments (Plasma, GNOME)
- **features/** - Optional features (gaming, virtualization, development, printing)
- **security/** - Security settings (firewall, SSH, updates)
- **services/** - System services (timesyncd, earlyoom, etc.)
- **packages/** - System-wide packages (split by category)

## Usage

Import modules in your host configuration:

```nix
imports = [
  ../../modules/nixos/core
  ../../modules/nixos/hardware
  ../../modules/nixos/desktop
  ../../modules/nixos/features
  ../../modules/nixos/security
  ../../modules/nixos/services
  ../../modules/nixos/packages
];
```

## Module Organization

Each category has a `default.nix` that aggregates related modules. This allows you to import entire categories at once.

## Feature Flags

Many modules are controlled by feature flags defined in `hosts/<hostname>/features.nix`. See `FEATURES.md` for complete reference.


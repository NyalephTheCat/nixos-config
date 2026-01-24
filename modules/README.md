# Modules Directory

This directory contains all NixOS and Home Manager modules organized by scope and purpose.

## Structure

```
modules/
├── nixos/          # System-level NixOS modules
└── home-manager/   # User-level Home Manager modules
```

## NixOS Modules

System-level modules that affect the entire system. See `nixos/README.md` for details.

**Categories:**
- `core/` - Essential system (boot, locale, networking, nix)
- `hardware/` - Hardware support
- `desktop/` - Desktop environments
- `features/` - Optional features
- `security/` - Security settings
- `services/` - System services
- `packages/` - System-wide packages

## Home Manager Modules

User-level modules that configure individual user environments. See `home-manager/README.md` for details.

**Categories:**
- `programs/` - Program configurations
- `packages/` - User packages
- `features/` - Optional user features

## Module Design Principles

1. **Separation of Concerns**: System vs user-level clearly separated
2. **Modularity**: Each module has a single responsibility
3. **Aggregation**: Categories use `default.nix` to aggregate related modules
4. **Feature Flags**: Optional modules controlled by feature flags
5. **Documentation**: Each category is self-documenting

## Adding New Modules

1. Determine if it's system-level (nixos/) or user-level (home-manager/)
2. Choose appropriate category or create new one
3. Create module file with proper structure
4. Add to category's `default.nix` if applicable
5. Document in category README if needed

## Importing Modules

**In host configuration:**
```nix
imports = [
  ../../modules/nixos/core
  ../../modules/nixos/hardware
  # etc.
];
```

**In user configuration:**
```nix
imports = [
  ../../modules/home-manager/programs
  ../../modules/home-manager/features
];
```

See individual category READMEs for more details.


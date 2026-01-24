# Architecture Decision Log

This document records the key architectural decisions made in this multi-host NixOS configuration.

## Decision 1: Multi-Host with Shared Modules

**Date:** 2026-01-24

**Context:**
We needed to support two systems (heaven and agz-pc) with different configurations while minimizing code duplication.

**Decision:**
- Use a flake-based multi-host setup
- Create shared modules under `modules/nixos/` and `modules/home-manager/`
- Each host has its own directory under `hosts/` with feature flags

**Rationale:**
- DRY (Don't Repeat Yourself) principle
- Easy to maintain shared configuration
- Simple to add new hosts
- Clear separation of concerns

**Consequences:**
- Easier to maintain across multiple systems
- Changes to shared modules affect all hosts
- Requires understanding of module system

## Decision 2: Feature Flag System

**Date:** 2026-01-24

**Context:**
Different hosts need different features (gaming, virtualization, etc.) without code duplication.

**Decision:**
- Implement feature flags in `features.nix` per host
- Use `lib.mkIf` for conditional loading
- Support both host-level and user-level features

**Rationale:**
- Easy to enable/disable features per host
- Clear declaration of what each system includes
- Avoids conditional imports scattered across files

**Consequences:**
- Very easy to customize per-host
- Requires setting up features.nix for new hosts
- Need to ensure feature flags are checked correctly

## Decision 3: Separate NixOS and Home Manager Modules

**Date:** 2026-01-24

**Context:**
System-level configuration (NixOS) and user-level configuration (Home Manager) have different scopes.

**Decision:**
- Split modules into `modules/nixos/` for system-level
- Split modules into `modules/home-manager/` for user-level
- Clear naming convention

**Rationale:**
- Clear separation between system and user concerns
- Easier to understand which module affects what
- Supports multiple users per host
- Follows Nix best practices

**Consequences:**
- More organized code structure
- Easier to reason about module scope
- Can easily support multiple users on same host

## Decision 4: Per-User Configuration

**Date:** 2026-01-24

**Context:**
Each user has different preferences, packages, and git configuration.

**Decision:**
- Each user gets their own directory under `users/`
- User-specific packages in `packages.nix`
- User-specific settings in `home.nix`
- Feature flags at user level too

**Rationale:**
- Users have different needs and preferences
- Keeps user-specific config separate and portable
- Easy to move user config to different host

**Consequences:**
- Very flexible per-user customization
- User configs are reusable across hosts
- Need to maintain separate configs per user

## Decision 5: lib/ Helper Functions

**Date:** 2026-01-24

**Context:**
Creating hosts and users involves repetitive code.

**Decision:**
- Create `lib/default.nix` with helper functions
- `mkHost` function to simplify host creation
- `lib/options.nix` for custom option definitions

**Rationale:**
- Reduces boilerplate in flake.nix
- Makes adding new hosts easier
- Centralizes common patterns

**Consequences:**
- Cleaner flake.nix
- Easier to add new hosts
- One place to update host creation logic

## Decision 6: Conditional Loading with lib.mkDefault

**Date:** 2026-01-24

**Context:**
Modules need to provide sensible defaults that can be overridden per-host.

**Decision:**
- Use `lib.mkDefault` for all shared module options
- Host configs can override without conflict
- Use `lib.mkIf` for conditional feature loading

**Rationale:**
- Allows per-host customization
- Prevents merge conflicts
- Follows NixOS module best practices

**Consequences:**
- More flexible configuration
- Clear precedence: host config > shared modules
- Requires understanding of NixOS option priorities

## Decision 7: Helper Scripts

**Date:** 2026-01-24

**Context:**
Deploying to specific hosts requires remembering correct commands.

**Decision:**
- Use direct nixos-rebuild commands for deployment
- One script per host for deployment
- Additional scripts for common tasks

**Rationale:**
- Easier for non-experts to deploy
- Reduces typos in commands
- Self-documenting through script names

**Consequences:**
- More convenient deployment
- Scripts need to be maintained
- Scripts need execute permissions

## Decision 8: Performance vs Security Tradeoffs

**Date:** 2026-01-24

**Context:**
CPU mitigations impact performance but improve security.

**Decision:**
- Disable CPU mitigations by default (`mitigations=off`)
- Document this decision clearly
- Easy to enable per-host in features if needed

**Rationale:**
- Desktop systems prioritize performance
- Users are aware of the tradeoff
- Can be changed per-host

**Consequences:**
- Better performance for desktop workloads
- Slightly reduced security
- Clear documentation of tradeoff

## Decision 9: Zram over Traditional Swap

**Date:** 2026-01-24

**Context:**
Modern systems benefit from compressed RAM over disk swap.

**Decision:**
- Use zram with zstd compression
- Set to 50% of RAM by default
- Can be configured per-host

**Rationale:**
- Much faster than disk swap
- Better for systems with sufficient RAM
- Reduces disk wear

**Consequences:**
- Better performance under memory pressure
- Uses some RAM for compression
- Well-suited for desktop systems

## Decision 10: Plasma 6 as Default Desktop

**Date:** 2026-01-24

**Context:**
Need to choose a default desktop environment.

**Decision:**
- KDE Plasma 6 as default
- GNOME available as alternative
- Easy to switch via feature flags

**Rationale:**
- Plasma 6 is modern and feature-rich
- Works well on both systems
- Easy to customize

**Consequences:**
- Consistent default experience
- Can be changed per-host
- Both users can have different DEs if desired

## Decision 11: System-Wide Zsh Configuration

**Date:** 2026-01-24

**Context:**
Shell configuration needed at both system and user levels.

**Decision:**
- Enable Zsh system-wide with Oh My Zsh
- Additional user-specific customization in Home Manager
- Common aliases at system level

**Rationale:**
- Consistent shell experience
- Oh My Zsh provides good defaults
- Users can override as needed

**Consequences:**
- All users get Zsh by default
- Consistent command aliases
- Easy to customize per-user

## Decision 12: Flatpak Support

**Date:** 2026-01-24

**Context:**
Some applications are easier to install via Flatpak.

**Decision:**
- Enable Flatpak system-wide
- Used for specific applications (Hytale launcher)

**Rationale:**
- Access to applications not in nixpkgs
- Easier for some proprietary software
- User-friendly for non-Nix applications

**Consequences:**
- More package sources available
- Some applications use Flatpak
- Need to manage both Nix and Flatpak packages

## Decision 13: Overlays and Custom Packages System

**Date:** 2026-01-24

**Context:**
Need a way to override packages and add custom packages without modifying nixpkgs directly.

**Decision:**
- Use overlays system from nixpkgs
- Define overlays in `overlays/default.nix`
- Custom packages in `pkgs/default.nix` available via specialArgs
- Overlays automatically applied in flake.nix

**Rationale:**
- Clean separation of package modifications
- Reusable across all hosts
- Follows NixOS best practices
- Easy to maintain and version control

**Consequences:**
- All hosts automatically get overlay benefits
- Custom packages accessible in modules
- Easy to add per-host overlays if needed

## Decision 14: Per-Host Nixpkgs Configuration

**Date:** 2026-01-24

**Context:**
Different hosts may need different nixpkgs settings (allowUnfree, permittedInsecurePackages, etc.).

**Decision:**
- Support per-host nixpkgs configuration via `hosts/hostname/nixpkgs.nix`
- Or configure directly in flake.nix via `nixpkgsConfig` parameter
- Merge with defaults (host-specific overrides module defaults)

**Rationale:**
- Flexibility for different host requirements
- Clear per-host customization
- Backward compatible with module-level defaults

**Consequences:**
- Each host can have custom nixpkgs settings
- Easy to see host-specific configuration
- Supports multi-architecture setups

## Decision 15: Library Function Organization

**Date:** 2026-01-24

**Context:**
Helper functions were scattered and some duplication existed between flake.nix and lib/default.nix.

**Decision:**
- Centralize all helper functions in `lib/` directory
- Split into logical files: `lib/packages.nix`, `lib/host.nix`
- Re-export from `lib/default.nix` for convenience
- Use lib/default.nix mkHost in flake.nix (eliminate duplication)

**Rationale:**
- Single source of truth for helper functions
- Better organization and discoverability
- Easier to test and maintain
- Clear separation of concerns

**Consequences:**
- All helpers available via lib import
- Better code organization
- Easier to extend with new utilities

## Decision 16: Multi-Architecture Support

**Date:** 2026-01-24

**Context:**
Configuration should support different architectures (x86_64-linux, aarch64-linux, etc.).

**Decision:**
- Make system architecture configurable per-host in flake.nix
- Default to x86_64-linux for backward compatibility
- Support architecture-specific nixpkgs and packages

**Rationale:**
- Future-proof for ARM systems
- Easy to add new architectures
- Per-host flexibility

**Consequences:**
- Can configure different architectures per-host
- Packages output organized by system
- Ready for ARM-based systems

## Future Decisions to Consider

1. **Secrets Management:** Implement sops-nix for encrypted secrets
2. **CI/CD:** Add GitHub Actions for automated testing
3. **Remote Deployment:** Consider deploy-rs or colmena for remote management
4. **Impermanence:** Consider implementing ephemeral root filesystem
5. **Backup Strategy:** Implement automated backup solution

---

## How to Use This Document

When making significant architectural changes:
1. Document the decision with date, context, rationale
2. Note the consequences (both positive and negative)
3. Explain why alternatives were rejected
4. Update this log before merging changes

This helps future maintainers understand why the system is structured this way.


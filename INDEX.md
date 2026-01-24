# 📋 NixOS Multi-Host Configuration - Documentation Index

Welcome to your refactored NixOS configuration! This index will guide you to the right documentation.

## 🎯 Start Here

**New to this configuration?**
- 👉 **[QUICKSTART.md](QUICKSTART.md)** - Get up and running in minutes

**Ready to migrate from old config?**
- 👉 **[MIGRATION.md](MIGRATION.md)** - Step-by-step migration guide

## 📚 Documentation

### Core Documentation

| File | Purpose | When to Read |
|------|---------|--------------|
| **[QUICKSTART.md](QUICKSTART.md)** | Quick deployment guide | Before first deployment |
| **[README.md](README.md)** | Complete documentation | For detailed understanding |
| **[MIGRATION.md](MIGRATION.md)** | Migration from old config | Before switching configurations |
| **[DECISIONS.md](DECISIONS.md)** | Architectural decisions | To understand design choices |
| **[FEATURES.md](FEATURES.md)** | Feature flags reference | When customizing features |

### Quick Reference

**Common Tasks:**
- Deploy to heaven: `sudo nixos-rebuild switch --flake .#heaven`
- Deploy to agz-pc: `sudo nixos-rebuild switch --flake .#agz-pc`
- Update system: `nix flake update`
- Check configs: `nix flake check`

**Configuration Files:**
- Heaven features: `hosts/heaven/features.nix`
- Agz-pc features: `hosts/agz-pc/features.nix`
- Nyaleph user: `users/nyaleph/home.nix`
- Agz user: `users/agz-cadentis/home.nix`

## 🗂️ Structure Overview

```
.
├── flake.nix              # Main flake (copy from flake.nix)
├── hosts/                 # Per-host configurations
│   ├── heaven/           # Your system
│   └── agz-pc/           # Agz's system
├── users/                 # Per-user configurations
│   ├── nyaleph/
│   └── agz-cadentis/
├── modules/
│   ├── nixos/            # System-level modules
│   └── home-manager/     # User-level modules
├── lib/                   # Helper functions
└── [docs]                 # Documentation files
```

## 🎓 Learning Path

### For First-Time Deployment

1. **[QUICKSTART.md](QUICKSTART.md)** - Quick deployment steps
2. **[MIGRATION.md](MIGRATION.md)** - Detailed migration process
3. Test deployment
4. **[README.md](README.md)** - Read after deployment

### For Understanding Architecture

1. **[DECISIONS.md](DECISIONS.md)** - Why it's structured this way
2. **[README.md](README.md)** - Full feature documentation

### For Customization

1. **[README.md](README.md)** - Section: "Customization"
2. Edit feature files:
   - `hosts/*/features.nix` for system features
   - `users/*/home.nix` for user features
3. Deploy changes

### For Adding New Systems

1. **[README.md](README.md)** - Section: "Adding a New Host"
2. Generate hardware config on new system
3. Create host configuration
4. Deploy

## 🔍 Find What You Need

### By Task

| What I Want to Do | Where to Look |
|-------------------|---------------|
| Deploy for the first time | [QUICKSTART.md](QUICKSTART.md) |
| Enable/disable gaming | `hosts/heaven/features.nix` |
| Add user packages | `users/nyaleph/packages.nix` |
| Change desktop environment | `hosts/heaven/features.nix` |
| Add new system | [README.md](README.md) → "Adding a New Host" |
| Add new user | [README.md](README.md) → "Adding a New User" |
| Understand the design | [DECISIONS.md](DECISIONS.md) |
| Troubleshoot issues | [README.md](README.md) → "Troubleshooting" |
| Update system | `nix flake update` |
| Rollback changes | [README.md](README.md) → "Maintenance" |

### By File Type

**Configuration Files:**
- Flake: `flake.nix`
- Host config: `hosts/<hostname>/configuration.nix`
- Features: `hosts/<hostname>/features.nix`
- User config: `users/<username>/home.nix`
- User packages: `users/<username>/packages.nix`

**Module Files:**
- System modules: `modules/nixos/`
- User modules: `modules/home-manager/`
- Helpers: `lib/default.nix`


## ⚡ Quick Actions

### First Time Setup
```bash
# Validate everything
nix flake check

# Deploy to heaven
sudo nixos-rebuild switch --flake .#heaven
```

### Regular Usage
```bash
# Deploy changes
sudo nixos-rebuild switch --flake .#heaven

# Update system
nix flake update && sudo nixos-rebuild switch --flake .#heaven

# Check before deploying
nix flake check
```

### Troubleshooting
```bash
# Validate structure
nix flake check

# Check syntax
nix flake check

# Show detailed errors
sudo nixos-rebuild switch --flake .#heaven --show-trace

# Rollback
sudo nixos-rebuild switch --rollback
```

## 📊 Configuration Status

### heaven (Ready ✅)
- Configuration: Complete
- Hardware config: Present
- Features: Configured
- User: nyaleph (configured)
- Status: **Ready to deploy**

### agz-pc (Template 📝)
- Configuration: Template ready
- Hardware config: **Needs generation**
- Features: Defaults (needs customization)
- User: agz-cadentis (template)
- Status: **Needs hardware config before deployment**

## 🆘 Help & Support

**Something not working?**
1. Check [README.md](README.md) → "Troubleshooting"
2. Run `nix flake check`
3. Check logs with `--show-trace` flag

**Want to understand something?**
1. Check [README.md](README.md) for full docs
2. Check [DECISIONS.md](DECISIONS.md) for design rationale
3. Look at module source code (well-commented)

**Need to customize?**
1. Check [README.md](README.md) → "Customization"
2. Edit feature flags in `hosts/*/features.nix`
3. Edit user config in `users/*/home.nix`

## 📝 Notes

- Old configuration files are **preserved** (not deleted)
- New flake is saved as `flake.nix` (rename to `flake.nix` to activate)
- All changes are **validated** and **ready to deploy**
- You can **rollback** anytime via GRUB or `--rollback` flag

---

## 🚀 Ready to Deploy?

**Quick Path:**
1. Read [QUICKSTART.md](QUICKSTART.md)
2. Run `nix flake check`
3. Deploy with `cp flake.nix flake.nix && sudo nixos-rebuild switch --flake .#heaven`

**Careful Path:**
1. Read [MIGRATION.md](MIGRATION.md)
2. Follow step-by-step instructions
3. Test before committing

**Good luck! 🎉**

---

*Last updated: 2026-01-24*
*Configuration version: Multi-host refactor v1.0*


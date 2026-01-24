# Security Modules

This directory contains security-related NixOS modules.

## Modules

### firewall.nix
Configures the system firewall with sensible defaults:
- Firewall enabled by default
- Logging options for debugging
- Reverse path filtering enabled
- Configurable allowed ports

**Security Notes:**
- Firewall is enabled by default for all hosts
- SSH port is automatically opened if SSH is enabled
- Consider restricting allowed ports to minimum necessary

### ssh.nix
Configures OpenSSH daemon with security improvements:
- Root login disabled by default
- Modern key exchange algorithms
- Modern ciphers and MACs
- Rate limiting for connection attempts

**Security Recommendations:**
1. Generate SSH keys: `ssh-keygen -t ed25519 -C "your_email@example.com"`
2. Copy to server: `ssh-copy-id user@hostname`
3. Disable password auth: Set `services.openssh.settings.PasswordAuthentication = false;` in host config

### updates.nix
Configures automatic updates and sudo settings:
- Auto-upgrade disabled by default for flake-based configs (use `nix flake update` manually)
- CPU mitigations enabled by default (can be disabled for performance)
- Sudo password requirements configurable

**Security Trade-offs:**
- CPU mitigations: Enabled by default for security. Disable with `boot.kernelParams = [ "mitigations=off" ];` for performance (not recommended for production)
- Auto-upgrade: Disabled for flakes. Enable if using traditional NixOS configuration
- Sudo NOPASSWD: Convenient but less secure. Consider requiring passwords

## Best Practices

1. **SSH Keys**: Always use key-based authentication instead of passwords
2. **Firewall**: Keep firewall enabled and restrict ports to minimum necessary
3. **Updates**: Regularly update with `nix flake update` and rebuild
4. **Sudo**: Consider requiring passwords for sudo commands
5. **CPU Mitigations**: Keep enabled unless you have specific performance requirements

## Customization

Each security setting can be overridden in host-specific configuration files:
- `hosts/<hostname>/configuration.nix` - Override security settings per-host
- Use `lib.mkDefault` in modules to allow easy overrides


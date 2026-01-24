{ config, pkgs, lib, ... }:

{
  # OpenSSH daemon
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = lib.mkDefault true; # Set to false if using keys only
      KbdInteractiveAuthentication = lib.mkDefault false;
      X11Forwarding = lib.mkDefault true;
      # Security improvements
      PermitEmptyPasswords = lib.mkDefault false;
      MaxAuthTries = lib.mkDefault 6;
      MaxSessions = lib.mkDefault 10;
      # Use modern key exchange algorithms
      KexAlgorithms = lib.mkDefault [
        "curve25519-sha256@libssh.org"
        "diffie-hellman-group-exchange-sha256"
      ];
      # Use modern ciphers
      Ciphers = lib.mkDefault [
        "chacha20-poly1305@openssh.com"
        "aes256-gcm@openssh.com"
        "aes128-gcm@openssh.com"
        "aes256-ctr"
        "aes192-ctr"
        "aes128-ctr"
      ];
      # Note: MACs setting removed due to duplicate key issue
      # OpenSSH will use secure defaults automatically
    };
    openFirewall = lib.mkDefault true;
  };

  # SSH key-based authentication helper
  # To set up SSH keys:
  # 1. Generate key: ssh-keygen -t ed25519 -C "your_email@example.com"
  # 2. Copy to server: ssh-copy-id user@hostname
  # 3. Disable password auth in host config: services.openssh.settings.PasswordAuthentication = false;
}


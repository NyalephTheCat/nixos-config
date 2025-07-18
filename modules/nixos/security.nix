{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.security;
in
{
  options.modules.security = {
    enable = mkEnableOption "security hardening";
    
    kernel = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable kernel hardening";
      };
      
      hideProcesses = mkOption {
        type = types.bool;
        default = true;
        description = "Hide processes from other users";
      };
    };
    
    firewall = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable strict firewall rules";
      };
      
      allowedTCPPorts = mkOption {
        type = types.listOf types.port;
        default = [];
        description = "Additional TCP ports to allow";
      };
      
      allowedUDPPorts = mkOption {
        type = types.listOf types.port;
        default = [];
        description = "Additional UDP ports to allow";
      };
      
      logDropped = mkOption {
        type = types.bool;
        default = false;
        description = "Log dropped packets";
      };
    };
    
    ssh = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable SSH hardening";
      };
      
      port = mkOption {
        type = types.port;
        default = 22;
        description = "SSH port";
      };
      
      passwordAuthentication = mkOption {
        type = types.bool;
        default = false;
        description = "Allow password authentication";
      };
      
      rootLogin = mkOption {
        type = types.bool;
        default = false;
        description = "Allow root login";
      };
      
      fail2ban = mkOption {
        type = types.bool;
        default = true;
        description = "Enable fail2ban for SSH";
      };
    };
    
    auditd = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable system auditing";
      };
    };
    
    apparmor = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable AppArmor";
      };
    };
    
    sudo = {
      wheelNeedsPassword = mkOption {
        type = types.bool;
        default = true;
        description = "Require password for wheel group sudo";
      };
      
      timeout = mkOption {
        type = types.int;
        default = 5;
        description = "Sudo password timeout in minutes";
      };
    };
    
    networking = {
      enableIPv6 = mkOption {
        type = types.bool;
        default = false;
        description = "Enable IPv6 (disable if not needed)";
      };
      
      tcpFastOpen = mkOption {
        type = types.bool;
        default = false;
        description = "Enable TCP Fast Open";
      };
    };
  };

  config = mkIf cfg.enable {
    # Kernel hardening
    boot = mkIf cfg.kernel.enable {
      kernelModules = [ "tcp_bbr" ];
      
      kernel.sysctl = {
        # Network hardening
        "net.ipv4.conf.all.rp_filter" = 1;
        "net.ipv4.conf.default.rp_filter" = 1;
        "net.ipv4.conf.all.accept_redirects" = 0;
        "net.ipv4.conf.all.send_redirects" = 0;
        "net.ipv4.conf.all.accept_source_route" = 0;
        "net.ipv4.conf.default.accept_redirects" = 0;
        "net.ipv4.conf.default.send_redirects" = 0;
        "net.ipv4.conf.default.accept_source_route" = 0;
        "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
        "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
        "net.ipv4.tcp_syncookies" = 1;
        "net.ipv4.tcp_rfc1337" = 1;
        "net.ipv4.tcp_fastopen" = mkIf cfg.networking.tcpFastOpen 3;
        "net.ipv4.tcp_congestion_control" = "bbr";
        
        # IPv6 hardening
        "net.ipv6.conf.all.accept_redirects" = 0;
        "net.ipv6.conf.default.accept_redirects" = 0;
        "net.ipv6.conf.all.accept_source_route" = 0;
        "net.ipv6.conf.all.disable_ipv6" = mkIf (!cfg.networking.enableIPv6) 1;
        "net.ipv6.conf.default.disable_ipv6" = mkIf (!cfg.networking.enableIPv6) 1;
        
        # Kernel hardening
        "kernel.dmesg_restrict" = 1;
        "kernel.kptr_restrict" = 2;
        "kernel.yama.ptrace_scope" = 1;
        "kernel.unprivileged_bpf_disabled" = 1;
        "net.core.bpf_jit_harden" = 2;
        "kernel.ftrace_enabled" = false;
        "kernel.sysrq" = 0;
        
        # File system hardening
        "fs.suid_dumpable" = 0;
        "fs.protected_hardlinks" = 1;
        "fs.protected_symlinks" = 1;
        "fs.protected_fifos" = 2;
        "fs.protected_regular" = 2;
      };
      
      kernelParams = [
        "slab_nomerge"
        "page_alloc.shuffle=1"
        "randomize_kstack_offset=on"
        "vsyscall=none"
        "debugfs=off"
        "oops=panic"
        "quiet"
        "loglevel=0"
      ];
      
      # Blacklist unnecessary kernel modules
      blacklistedKernelModules = [
        "dccp"
        "sctp"
        "rds"
        "tipc"
        "n-hdlc"
        "ax25"
        "netrom"
        "x25"
        "rose"
        "decnet"
        "econet"
        "af_802154"
        "ipx"
        "appletalk"
        "psnap"
        "p8023"
        "p8022"
        "can"
        "atm"
        "cramfs"
        "freevxfs"
        "jffs2"
        "hfs"
        "hfsplus"
        "squashfs"
        "udf"
        "vivid"
        "bluetooth" # Comment out if using Bluetooth
        "btusb"     # Comment out if using Bluetooth
        "uvcvideo"  # Comment out if using webcam
      ];
    };
    
    # Process hiding
    security.hideProcessInformation = cfg.kernel.hideProcesses;
    
    # Firewall configuration
    networking.firewall = mkIf cfg.firewall.enable {
      enable = true;
      allowPing = false;
      logReversePathDrops = cfg.firewall.logDropped;
      allowedTCPPorts = cfg.firewall.allowedTCPPorts;
      allowedUDPPorts = cfg.firewall.allowedUDPPorts;
      
      extraCommands = ''
        # Drop invalid packets
        iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
        
        # Rate limiting
        iptables -A INPUT -p tcp --dport ${toString cfg.ssh.port} -m state --state NEW -m recent --set
        iptables -A INPUT -p tcp --dport ${toString cfg.ssh.port} -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
        
        # Block port scanning
        iptables -N port-scanning
        iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
        iptables -A port-scanning -j DROP
      '';
    };
    
    # SSH hardening
    services.openssh = mkIf cfg.ssh.enable {
      enable = true;
      ports = [ cfg.ssh.port ];
      settings = {
        PasswordAuthentication = cfg.ssh.passwordAuthentication;
        PermitRootLogin = if cfg.ssh.rootLogin then "yes" else "no";
        ChallengeResponseAuthentication = false;
        X11Forwarding = false;
        UsePAM = true;
        PrintMotd = false;
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        MaxAuthTries = 3;
        MaxSessions = 2;
        TCPKeepAlive = "no";
        Compression = "no";
        AllowAgentForwarding = "no";
        AllowStreamLocalForwarding = "no";
        AuthenticationMethods = "publickey";
      };
      
      extraConfig = ''
        Protocol 2
        StrictModes yes
        IgnoreRhosts yes
        HostbasedAuthentication no
        PermitEmptyPasswords no
        PermitUserEnvironment no
        Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
        MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com
        KexAlgorithms sntrup761x25519-sha512@openssh.com,curve25519-sha256,curve25519-sha256@libssh.org
        HostKeyAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256
      '';
    };
    
    # Fail2ban
    services.fail2ban = mkIf (cfg.ssh.enable && cfg.ssh.fail2ban) {
      enable = true;
      maxretry = 3;
      bantime = "1h";
      bantime-increment.enable = true;
      
      jails = {
        ssh-iptables = ''
          enabled = true
          port = ${toString cfg.ssh.port}
          filter = sshd
          logpath = /var/log/auth.log
          backend = systemd
          maxretry = 3
          findtime = 600
          bantime = 3600
        '';
      };
    };
    
    # Auditd
    security.auditd.enable = cfg.auditd.enable;
    security.audit = mkIf cfg.auditd.enable {
      enable = true;
      rules = [
        "-a exit,always -F arch=b64 -S execve"
        "-w /etc/passwd -p wa -k passwd_changes"
        "-w /etc/group -p wa -k group_changes"
        "-w /etc/shadow -p wa -k shadow_changes"
        "-w /etc/sudoers -p wa -k sudoers_changes"
        "-w /etc/ssh/sshd_config -p wa -k sshd_config_changes"
      ];
    };
    
    # AppArmor
    security.apparmor = mkIf cfg.apparmor.enable {
      enable = true;
      killUnconfinedConfinables = true;
    };
    
    # Sudo configuration
    security.sudo = {
      wheelNeedsPassword = cfg.sudo.wheelNeedsPassword;
      execWheelOnly = true;
      extraConfig = ''
        Defaults passwd_timeout=${toString cfg.sudo.timeout}
        Defaults timestamp_timeout=${toString cfg.sudo.timeout}
        Defaults requiretty
        Defaults use_pty
        Defaults logfile="/var/log/sudo.log"
        Defaults lecture="always"
        Defaults lecture_file="${pkgs.writeText "sudo-lecture" ''
          This is a protected system. All actions are logged and monitored.
          Unauthorized access is prohibited and will be prosecuted.
        ''}"
      '';
    };
    
    # Additional security packages
    environment.systemPackages = with pkgs; [
      aide # File integrity checker
      rkhunter # Rootkit hunter
      chkrootkit # Another rootkit checker
      lynis # Security auditing tool
      vulnix # Nix vulnerability scanner
    ] ++ optionals cfg.firewall.enable [
      iptables
      nftables
    ];
    
    # Security-related services
    services.clamav = {
      daemon.enable = true;
      updater.enable = true;
    };
    
    # Disable unnecessary services
    services.avahi.enable = mkDefault false;
    
    # User security
    users.mutableUsers = false;
    
    # Nix security
    nix.settings = {
      allowed-users = [ "@wheel" ];
      trusted-users = [ "root" "@wheel" ];
    };
  };
}
{ config, pkgs, lib, ... }:

{
  # Thunderbird email client configuration
  programs.thunderbird = {
    enable = true;
    
    # Profiles configuration
    profiles = {
      default = {
        isDefault = true;
        # Email account configuration
        # You can add accounts here or configure them manually in Thunderbird
        # Example configuration for common email providers:
        
        # Gmail example:
        # settings = {
        #   "mail.server.server1.hostname" = "imap.gmail.com";
        #   "mail.server.server1.type" = "imap";
        #   "mail.server.server1.port" = 993;
        #   "mail.server.server1.socketType" = 1; # SSL
        #   "mail.server.server1.username" = "your-email@gmail.com";
        #   "mail.smtpserver.smtp1.hostname" = "smtp.gmail.com";
        #   "mail.smtpserver.smtp1.port" = 587;
        #   "mail.smtpserver.smtp1.username" = "your-email@gmail.com";
        #   "mail.smtpserver.smtp1.try_ssl" = 2; # STARTTLS
        # };
        
        # Outlook/Office365 example:
        # settings = {
        #   "mail.server.server1.hostname" = "outlook.office365.com";
        #   "mail.server.server1.type" = "imap";
        #   "mail.server.server1.port" = 993;
        #   "mail.server.server1.socketType" = 1; # SSL
        #   "mail.server.server1.username" = "your-email@outlook.com";
        #   "mail.smtpserver.smtp1.hostname" = "smtp.office365.com";
        #   "mail.smtpserver.smtp1.port" = 587;
        #   "mail.smtpserver.smtp1.username" = "your-email@outlook.com";
        #   "mail.smtpserver.smtp1.try_ssl" = 2; # STARTTLS
        # };
        
        # Generic IMAP/SMTP example:
        # settings = {
        #   "mail.server.server1.hostname" = "mail.example.com";
        #   "mail.server.server1.type" = "imap";
        #   "mail.server.server1.port" = 993;
        #   "mail.server.server1.socketType" = 1; # SSL (0=plain, 1=SSL, 2=STARTTLS)
        #   "mail.server.server1.username" = "your-email@example.com";
        #   "mail.smtpserver.smtp1.hostname" = "smtp.example.com";
        #   "mail.smtpserver.smtp1.port" = 587;
        #   "mail.smtpserver.smtp1.username" = "your-email@example.com";
        #   "mail.smtpserver.smtp1.try_ssl" = 2; # STARTTLS
        # };
      };
    };
    
    # General Thunderbird settings
    settings = {
      # Enable automatic updates
      "app.update.auto" = true;
      "app.update.enabled" = true;
      
      # Mail settings
      "mail.default_send_format" = 1; # HTML
      "mail.compose.default_to_paragraph" = false;
      "mail.spellcheck.inline" = true;
      
      # Security settings
      "mailnews.display.prefer_plaintext" = false;
      "mailnews.display.html_as" = 1; # Sanitized HTML
      
      # Performance
      "mailnews.database.global.indexer.enabled" = true;
      
      # UI settings
      "mail.pane_config.dynamic" = true;
      "mail.pane_config.imap_expanded" = true;
    };
  };
}


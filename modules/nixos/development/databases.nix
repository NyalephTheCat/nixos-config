{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.modules.development.databases;
in
{
  options.modules.development.databases = {
    enable = mkEnableOption "database development tools";
    
    postgresql = {
      enable = mkEnableOption "PostgreSQL database";
      
      package = mkOption {
        type = types.package;
        default = pkgs.postgresql_16;
        description = "PostgreSQL package to use";
      };
      
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/postgresql";
        description = "PostgreSQL data directory";
      };
      
      authentication = mkOption {
        type = types.lines;
        default = ''
          local all all trust
          host all all 127.0.0.1/32 trust
          host all all ::1/128 trust
        '';
        description = "PostgreSQL authentication configuration";
      };
      
      extensions = mkOption {
        type = types.listOf types.package;
        default = with pkgs.postgresql16Packages; [
          postgis
          pgvector
          timescaledb
        ];
        description = "PostgreSQL extensions to install";
      };
    };
    
    mysql = {
      enable = mkEnableOption "MySQL/MariaDB database";
      
      package = mkOption {
        type = types.package;
        default = pkgs.mariadb;
        description = "MySQL/MariaDB package to use";
      };
      
      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/mysql";
        description = "MySQL data directory";
      };
    };
    
    redis = {
      enable = mkEnableOption "Redis key-value store";
      
      port = mkOption {
        type = types.port;
        default = 6379;
        description = "Redis port";
      };
    };
    
    mongodb = {
      enable = mkEnableOption "MongoDB document database";
      
      package = mkOption {
        type = types.package;
        default = pkgs.mongodb;
        description = "MongoDB package to use";
      };
    };
    
    elasticsearch = {
      enable = mkEnableOption "Elasticsearch search engine";
      
      package = mkOption {
        type = types.package;
        default = pkgs.elasticsearch;
        description = "Elasticsearch package to use";
      };
    };
    
    tools = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable database management tools";
      };
      
      gui = mkOption {
        type = types.bool;
        default = true;
        description = "Enable GUI database tools";
      };
    };
  };

  config = mkIf cfg.enable {
    # PostgreSQL
    services.postgresql = mkIf cfg.postgresql.enable {
      enable = true;
      package = cfg.postgresql.package;
      dataDir = cfg.postgresql.dataDir;
      authentication = cfg.postgresql.authentication;
      extensions = cfg.postgresql.extensions;
      
      settings = {
        shared_preload_libraries = "pg_stat_statements";
        "pg_stat_statements.track" = "all";
      };
      
      initialScript = pkgs.writeText "postgresql-init.sql" ''
        CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
        CREATE ROLE developer WITH LOGIN CREATEDB CREATEROLE;
      '';
    };
    
    # MySQL/MariaDB
    services.mysql = mkIf cfg.mysql.enable {
      enable = true;
      package = cfg.mysql.package;
      dataDir = cfg.mysql.dataDir;
      
      settings = {
        mysqld = {
          "bind-address" = "127.0.0.1";
          "port" = 3306;
          "character-set-server" = "utf8mb4";
          "collation-server" = "utf8mb4_unicode_ci";
        };
      };
      
      initialScript = pkgs.writeText "mysql-init.sql" ''
        CREATE USER IF NOT EXISTS 'developer'@'localhost';
        GRANT ALL PRIVILEGES ON *.* TO 'developer'@'localhost' WITH GRANT OPTION;
        FLUSH PRIVILEGES;
      '';
    };
    
    # Redis
    services.redis.servers."default" = mkIf cfg.redis.enable {
      enable = true;
      port = cfg.redis.port;
      bind = "127.0.0.1 ::1";
      save = [];
      
      settings = {
        loglevel = "notice";
        databases = 16;
        maxmemory-policy = "allkeys-lru";
      };
    };
    
    # MongoDB
    services.mongodb = mkIf cfg.mongodb.enable {
      enable = true;
      package = cfg.mongodb.package;
      bind_ip = "127.0.0.1";
    };
    
    # Elasticsearch
    services.elasticsearch = mkIf cfg.elasticsearch.enable {
      enable = true;
      package = cfg.elasticsearch.package;
      listenAddress = "127.0.0.1";
      
      extraJavaOptions = [
        "-Xms1g"
        "-Xmx1g"
      ];
    };
    
    # Database tools
    environment.systemPackages = with pkgs; 
      # CLI tools
      (optionals cfg.tools.enable [
        # PostgreSQL tools
        postgresql
        pgcli
        pspg # Better psql pager
        pg_top
        
        # MySQL tools
        mysql80
        mycli
        
        # Redis tools
        redis
        redis-dump
        
        # MongoDB tools
        mongosh
        mongodb-tools
        
        # Migration tools
        flyway
        liquibase
        
        # Backup tools
        pgbackrest
        mydumper
      ]) ++
      
      # GUI tools
      (optionals (cfg.tools.enable && cfg.tools.gui && config.services.xserver.enable) [
        dbeaver-bin
        pgadmin4
        robo3t # MongoDB GUI
        redisinsight
      ]);
    
    # Create database directories with proper permissions
    systemd.tmpfiles.rules = 
      (optionals cfg.postgresql.enable [
        "d ${cfg.postgresql.dataDir} 0700 postgres postgres -"
      ]) ++
      (optionals cfg.mysql.enable [
        "d ${cfg.mysql.dataDir} 0700 mysql mysql -"
      ]);
    
    # Open firewall for development (localhost only by default)
    networking.firewall = {
      allowedTCPPorts = [];  # Don't open external ports by default
      
      # Allow localhost connections
      extraCommands = ''
        ${optionalString cfg.postgresql.enable "iptables -A INPUT -p tcp --dport 5432 -s 127.0.0.1 -j ACCEPT"}
        ${optionalString cfg.mysql.enable "iptables -A INPUT -p tcp --dport 3306 -s 127.0.0.1 -j ACCEPT"}
        ${optionalString cfg.redis.enable "iptables -A INPUT -p tcp --dport ${toString cfg.redis.port} -s 127.0.0.1 -j ACCEPT"}
        ${optionalString cfg.mongodb.enable "iptables -A INPUT -p tcp --dport 27017 -s 127.0.0.1 -j ACCEPT"}
        ${optionalString cfg.elasticsearch.enable "iptables -A INPUT -p tcp --dport 9200 -s 127.0.0.1 -j ACCEPT"}
      '';
    };
  };
}
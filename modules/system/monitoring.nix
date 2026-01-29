{ config, pkgs, lib, ... }:

with lib;

let
  cfg = config.system.monitoring;
in
{
  options.system.monitoring = {
    enable = mkEnableOption "system monitoring tools";

    prometheus = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Prometheus monitoring.";
      };

      port = mkOption {
        type = types.port;
        default = 9090;
        description = "Prometheus web interface port.";
      };
    };

    grafana = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Grafana dashboard.";
      };

      port = mkOption {
        type = types.port;
        default = 3000;
        description = "Grafana web interface port.";
      };
    };

    nodeExporter = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Prometheus node exporter.";
      };

      port = mkOption {
        type = types.port;
        default = 9100;
        description = "Node exporter metrics port.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.prometheus = mkMerge [
      (mkIf cfg.prometheus.enable {
        enable = true;
        port = toString cfg.prometheus.port;
      })
      (mkIf cfg.nodeExporter.enable {
        exporters.node = {
          enable = true;
          port = toString cfg.nodeExporter.port;
        };
      })
    ];

    services.grafana = mkIf cfg.grafana.enable {
      enable = true;
      settings = {
        server = {
          http_port = cfg.grafana.port;
        };
      };
    };
  };
}

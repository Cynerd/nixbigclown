{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cnf = config.services.bigclown.mqtt2influxdb;
  filterNull = filterAttrsRecursive (n: v: v != null);
  configFile = (pkgs.formats.yaml {}).generate "bigclown-mqtt2influxdb-config.yaml" (
    filterNull {
      inherit (cnf) mqtt influxdb;
      points = map (v: filterNull v) cnf.points;
    }
  );

  pointType = types.submodule {
    options = {
      measurement = mkOption {
        type = types.str;
        description = "Name of the measurement";
      };
      topic = mkOption {
        type = types.str;
        description = "MQTT topic to subscribe to.";
      };
      fields = mkOption {
        type = types.submodule {
          options = {
            value = mkOption {
              type = types.str;
              default = "$.payload";
              description = "Value to be picked up";
            };
            type = mkOption {
              type = with types; nullOr str;
              default = null;
              description = "Type? TODO description";
            };
          };
        };
        description = "Field selector.";
      };
      tags = mkOption {
        type = with types; attrsOf str;
        default = {};
        description = "Tags applied";
      };
    };
  };

  defaultPoints = [
    {
      measurement = "temperature";
      topic = "node/+/thermometer/+/temperature";
      fields.value = "$.payload";
      tags = {
        id = "$.topic[1]";
        channel = "$.topic[3]";
      };
    }
    {
      measurement = "relative-humidity";
      topic = "node/+/hygrometer/+/relative-humidity";
      fields.value = "$.payload";
      tags = {
        id = "$.topic[1]";
        channel = "$.topic[3]";
      };
    }
    {
      measurement = "illuminance";
      topic = "node/+/lux-meter/0:0/illuminance";
      fields.value = "$.payload";
      tags = {
        id = "$.topic[1]";
      };
    }
    {
      measurement = "pressure";
      topic = "node/+/barometer/0:0/pressure";
      fields.value = "$.payload";
      tags = {
        id = "$.topic[1]";
      };
    }
    {
      measurement = "co2";
      topic = "node/+/co2-meter/-/concentration";
      fields.value = "$.payload";
      tags = {
        id = "$.topic[1]";
      };
    }
    {
      measurement = "voltage";
      topic = "node/+/battery/+/voltage";
      fields.value = "$.payload";
      tags = {
        id = "$.topic[1]";
      };
    }
    {
      measurement = "button";
      topic = "node/+/push-button/+/event-count";
      fields.value = "$.payload";
      tags = {
        id = "$.topic[1]";
        channel = "$.topic[3]";
      };
    }
    {
      measurement = "tvoc";
      topic = "node/+/voc-lp-sensor/0:0/tvoc";
      fields.value = "$.payload";
      tags = {
        id = "$.topic[1]";
      };
    }
  ];
in {
  options = {
    services.bigclown.mqtt2influxdb = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the BigClown MQTT to InfluxDB bridge.";
      };
      environmentFile = mkOption {
        type = with types; nullOr path;
        default = null;
        description = ''
          Systemd service environment file.
          You can use this to provide secret strings outside of the NixOS
          configuration. This is higly suggested to be used as otherwise your
          secretes end up publically readable in Nix store.
          By providing variable in the environment file you can use anywhere in
          the strings for bigclown-mqtt2influxdb syntax '@PASSWORD@' for line in
          systemd 'PASSWORD=foo'.
        '';
      };
      mqtt = {
        host = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Host where MQTT server is running.";
        };
        port = mkOption {
          type = types.int;
          default = 1883;
          description = "MQTT server port";
        };
        username = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "MQTT username";
        };
        password = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "MQTT password";
        };
        cafile = mkOption {
          type = with types; nullOr path;
          default = null;
          description = "CA file for MQTT";
        };
        certfile = mkOption {
          type = with types; nullOr path;
          default = null;
          description = "Certificate file for MQTT";
        };
        keyfile = mkOption {
          type = with types; nullOr path;
          default = null;
          description = "Key file for MQTT";
        };
      };
      influxdb = {
        host = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Host where InfluxDB server is running.";
        };
        port = mkOption {
          type = types.int;
          default = 8086;
          description = "InfluxDB server port";
        };
        database = mkOption {
          type = types.str;
          description = "InfluxDB database.";
        };
        username = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "Username for InfluxDB login.";
        };
        password = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "Password for InfluxDB login.";
        };
        ssl = mkOption {
          type = types.bool;
          default = false;
          description = "Use SSL to connect to the InfluxDB server.";
        };
        verify_ssl = mkOption {
          type = types.bool;
          default = true;
          description = "Verify SSL certificate when connecting to the InfluxDB server.";
        };
      };
      points = mkOption {
        type = types.listOf pointType;
        default = defaultPoints;
        description = "Points to bridge from MQTT to InfluxDB.";
      };
    };
  };

  config = mkIf cnf.enable {
    systemd.services.bigclown-mqtt2influxdb = let
      envConfig = cnf.environmentFile != null;
      finalConfig =
        if envConfig
        then "$RUNTIME_DIRECTORY/config.yaml"
        else configFile;
    in {
      description = "BigClown MQTT to InfluxDB bridge";
      wantedBy = ["multi-user.target"];
      script = ''
        ${optionalString envConfig ''
          ${pkgs.gawk}/bin/awk '{
            for(varname in ENVIRON)
              gsub("@"varname"@", ENVIRON[varname])
            print
          }' "${configFile}" > "${finalConfig}"
        ''}
        exec ${pkgs.bigclown-mqtt2influxdb}/bin/mqtt2influxdb -dc ${finalConfig}
      '';
      serviceConfig.EnvironmentFile = mkIf envConfig (builtins.toString cnf.environmentFile);
    };
  };
}

{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cnf = config.services.bigclown.gateway;
  configFile = (pkgs.formats.yaml {}).generate "bigclown-gateway-config.yaml" (
    filterAttrsRecursive (n: v: v != null) {
      inherit (cnf) device name mqtt;
      retain_node_messages = cnf.retainNodeMessages;
      qos_node_messages = cnf.qosNodeMessages;
      base_topic_prefix = cnf.baseTopicPrefix;
      automatic_remove_kit_from_names = cnf.automaticRemoveKitFromNames;
      automatic_rename_kit_nodes = cnf.automaticRenameKitNodes;
      automatic_rename_generic_nodes = cnf.automaticRenameGenericNodes;
      automatic_rename_nodes = cnf.automaticRenameNodes;
    }
  );
in {
  options = {
    services.bigclown.gateway = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable the BigClown gateway.";
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
          the strings for bigclown-gateway syntax '@PASSWORD@' for line in
          systemd 'PASSWORD=foo'.
        '';
      };
      verbose = mkOption {
        type = types.enum ["CRITICAL" "ERROR" "WARNING" "INFO" "DEBUG"];
        default = "WARNING";
        description = "Verbosity level.";
      };
      device = mkOption {
        type = types.str;
        description = "Device name to configure gateway to use.";
      };
      name = mkOption {
        type = with types; nullOr str;
        default = null;
        description = ''
          Name for the device.
          support variables:
          * {ip} - ip address
          * {id} - the id of the connected usb-dongle or core-module

          null can be used for automatic detection from gateway firmware.
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
          description = "Port of MQTT server.";
        };
        username = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "MQTT server access username.";
        };
        password = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "MQTT server access password.";
        };
        cafile = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "CA file for MQTT server access.";
        };
        certfile = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "Certificate file for MQTT server access.";
        };
        keyfile = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "Key file for MQTT server access.";
        };
      };
      retainNodeMessages = mkOption {
        type = types.bool;
        default = false;
      };
      qosNodeMessages = mkOption {
        type = types.int;
        default = 1;
      };
      baseTopicPrefix = mkOption {
        type = types.str;
        default = "";
      };
      automaticRemoveKitFromNames = mkOption {
        type = types.bool;
        default = true;
      };
      automaticRenameKitNodes = mkOption {
        type = types.bool;
        default = true;
      };
      automaticRenameGenericNodes = mkOption {
        type = types.bool;
        default = true;
      };
      automaticRenameNodes = mkOption {
        type = types.bool;
        default = true;
      };
      rename = mkOption {
        type = with types; attrsOf str;
        default = {};
        description = "Rename nodes to different name.";
      };
    };
  };

  config = mkIf cnf.enable {
    environment.systemPackages = with pkgs; [
      pkgs.bigclown-gateway
      pkgs.bigclown-control-tool
    ];

    systemd.services.bigclown-gateway = let
      envConfig = cnf.environmentFile != null;
      finalConfig =
        if envConfig
        then "$RUNTIME_DIRECTORY/config.yaml"
        else configFile;
    in {
      description = "BigClown Gateway";
      wantedBy = ["multi-user.target"];
      script = ''
        ${optionalString envConfig ''
          ${pkgs.gawk}/bin/awk '{
            for(varname in ENVIRON)
              gsub("@"varname"@", ENVIRON[varname])
            print
          }' "${configFile}" > "${finalConfig}"
        ''}
        exec ${pkgs.bigclown-gateway}/bin/bcg -c ${finalConfig} -v ${cnf.verbose}
      '';
      serviceConfig.EnvironmentFile = mkIf envConfig (builtins.toString cnf.environmentFile);
    };
  };
}

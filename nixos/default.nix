self:
with builtins; let
  modules = {
    bigclown-gateway = import ./modules/bigclown-gateway.nix;
    bigclown-mqtt2influxdb = import ./modules/bigclown-mqtt2influxdb.nix;
  };
in
  modules
  // {
    default = {
      imports = attrValues modules;
      nixpkgs.overlays = [self.overlays.default];
    };
  }

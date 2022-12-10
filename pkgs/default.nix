{nixpkgs}:
with nixpkgs.lib; let
  python = nixpkgs.python3.override {
    packageOverrides = self: super: {
      py-expression-eval = self.callPackage ./py-expression-eval {};
    };
  };
  pythonPackages = python.pkgs;

  callPackage = nixpkgs.newScope sentinelPkgs;
  sentinelPkgs = {
    bigclown-gateway = pythonPackages.callPackage ./bigclown-gateway {};
    bigclown-mqtt2influxdb = pythonPackages.callPackage ./bigclown-mqtt2influxdb {};
    bigclown-firmware-tool = pythonPackages.callPackage ./bigclown-firmware-tool {};
    bigclown-control-tool = pythonPackages.callPackage ./bigclown-control-tool {};
  };
in
  sentinelPkgs

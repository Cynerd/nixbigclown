{
  description = "Big Clown Nix flake";

  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }:
    {
      overlays.default = final: prev: import ./pkgs {nixpkgs = prev;};
      nixosModules = import ./nixos self;
    }
    // flake-utils.lib.eachDefaultSystem (
      system: {
        packages = flake-utils.lib.filterPackages system (flake-utils.lib.flattenTree (
          import ./pkgs {nixpkgs = nixpkgs.legacyPackages."${system}";}
        ));

        # The legacyPackages imported as overlay allows us to use pkgsCross to
        # cross-compile those packages.
        legacyPackages = import nixpkgs {
          inherit system;
          overlays = [self.overlay];
          crossOverlays = [self.overlay];
        };

        formatter = nixpkgs.legacyPackages.${system}.alejandra;
      }
    );
}

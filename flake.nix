{
  description = "Big Clown Nix flake";

  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }:
    with nixpkgs.lib;
    with flake-utils.lib;
      {
        overlays.default = final: prev: import ./pkgs {nixpkgs = prev;};
        nixosModules = import ./nixos self;
      }
      // eachDefaultSystem (
        system: let
          pkgs = nixpkgs.legacyPackages."${system}";
        in {
          packages = filterPackages system (flattenTree (
            import ./pkgs {nixpkgs = pkgs;}
          ));

          # The legacyPackages imported as overlay allows us to use pkgsCross to
          # cross-compile those packages.
          legacyPackages = pkgs.extend self.overlays.default;

          formatter = pkgs.alejandra;
        }
      );
}

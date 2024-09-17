{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    zig.url = "github:mitchellh/zig-overlay";
    zls.url = "github:zigtools/zls";
  };

  outputs = { self, nixpkgs, flake-utils, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (final: prev: rec {
              zig = inputs.zig.packages.${system}."master";
              zls = inputs.zls.packages.${system}.default;
              tracy = import ./pkgs/tracy.nix { inherit pkgs inputs; };
            })
          ];
        };
      in {
        devShell =
          pkgs.mkShell { buildInputs = with pkgs; [ zig zls tracy ccls ]; };
      });
}

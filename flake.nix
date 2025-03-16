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
              zig-master = inputs.zig.packages.${system}."0.14.0";
              zls-master = inputs.zls.packages.${system}.default;
            })
          ];
        };
      in {
        devShell = pkgs.mkShell {
          RUST_SRC_PATH =
            "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
          buildInputs = with pkgs; [
            zig-master
            zls-master
            tracy-glfw
            ccls
            rustc
            cargo
            rust-analyzer
            clippy
            rustfmt
            (python3.withPackages (p: with p; [ seaborn python-lsp-server ]))
          ];
        };
      });
}

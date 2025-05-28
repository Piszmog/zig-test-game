{
  description = "Test Game setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, zig-overlay, ... }@inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ zig-overlay.overlays.default ];
        };
        
        zig = pkgs.zig_0_14;
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            zig
            pkg-config
            SDL2
            SDL2_ttf
          ];

          # Set environment variables
          PKG_CONFIG_PATH = "${pkgs.SDL2.dev}/lib/pkgconfig:${pkgs.SDL2_ttf}/lib/pkgconfig";
          
          shellHook = ''
            echo "Using Zig ${pkgs.zig.version}"
            export ZIG_SYSTEM_LINKER_HACK=1
          '';
        };
        
        # For backward compatibility
        devShell = self.devShells.${system}.default;
      }
    );
}

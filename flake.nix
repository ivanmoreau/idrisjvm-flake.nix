{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-root.url = "github:srid/flake-root";
    mission-control.url = "github:Platonic-Systems/mission-control";
  };

  outputs = inputs@{ self, nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [
        inputs.flake-root.flakeModule
        inputs.mission-control.flakeModule
      ];
      perSystem = { self', pkgs, lib, config, system, ... }: {
        packages.idris2_jvm = with pkgs; stdenv.mkDerivation {
            name = "idris-jvm";
            version = "0.6.0.2";
            depsBuildBuild = [ wget makeWrapper ];
            propagatedNativeBuildInputs = [ jdk17_headless ];
            src = pkgs.fetchzip {
              url = "https://github.com/mmhelloworld/idris-jvm/releases/download/latest/idris2-0.6.0.2.zip";
              sha256 = "sha256-fULm+KPSi/7ou4GXfO4U7DTOJB1oKTYGohjrYrb9FwU=";
            };
            installPhase = ''
              cp -r . $out/
              chmod 0664 "$out/exec/idris2"
              chmod +x "$out/exec/idris2"
              mkdir -p $out/bin
              makeWrapper $out/exec/idris2 $out/bin/idris2 \
                --set IDRIS2_PREFIX $out/env
            '';
          };

          packages.default = self'.packages.idris2_jvm;

        devShells.default = pkgs.mkShell {
            buildInputs = [ 
              self'.packages.default
            ];
          };
      };
    };
}

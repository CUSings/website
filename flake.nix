{
  description = "Flake utils demo";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      {
        devShells = {
          default = pkgs.mkShell {
            packages = [
              pkgs.hugo
              pkgs.go
              pkgs.git
              pkgs.coreutils
            ];
          };
        };
        apps = {
          publish = flake-utils.lib.mkApp {
            drv = pkgs.writeShellApplication {
              name = "script";
              runtimeInputs = [
                pkgs.git
                pkgs.go
                pkgs.hugo
                pkgs.coreutils
              ];
              text = ''
                hash=$(git rev-parse --short HEAD)
                date=$(date '+%Y-%M-%d %H:%M:%S')
                mkdir public
                git -C public pull https://github.com/CUSings/website.git
                git switch gh-pages
                hugo
                git -C public add -A
                git -C public commit -m "Update $date $hash"
                git -C public push
              '';
            };
          };
        };
      }
    );
}

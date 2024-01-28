{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    marlowe-cardano.url = "github:input-output-hk/marlowe-cardano";
  };
  outputs = { self, nixpkgs, flake-utils, marlowe-cardano }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        marlowe-cli = marlowe-cardano.packages.${system}.marlowe-cli;
        loopScript = pkgs.writeTextDir "app/loop.sh" (builtins.readFile ./loop.sh);
        activeScript = pkgs.writeTextDir "app/active.sql" (builtins.readFile ./active.sql);
        image = pkgs.dockerTools.buildImage {
          name = "marlowe-clean";
          tag = "latest";
          copyToRoot = pkgs.buildEnv {
            name = "image-root";
            pathsToLink = [ "/bin" "/app" ];
            paths = [
              loopScript
              activeScript
              marlowe-cli
              pkgs.bash
              pkgs.coreutils
              pkgs.curl
              pkgs.jq
              pkgs.postgresql
            ];
          };
          config = {
            Cmd = [ "${pkgs.bash}/bin/bash" "loop.sh" ];
            WorkingDir = "/app";
          };
        };
      in
        {
          defaultPackage = image;
          packages = { marlowe-clean = image; };
        }
    );
}

{
  description = "URPS: Uniform Random Peer Sampler";

  outputs = { self, nix, nixpkgs }:

    let
      supportedSystems = [
        "x86_64-linux" "aarch64-linux" "armv7l-linux"
        "x86_64-darwin" "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs supportedSystems (system: f system);
    in
      {
        overlay = final: prev: {
          ocaml-urps =
            with final;
            ocamlPackages.buildDunePackage rec {
              pname = "urps";
              version = "0.0.1";
              src = self;
              useDune2 = true;

              nativeBuildInputs = with ocamlPackages; [
                odoc
              ];
              buildInputs = with ocamlPackages; [
                nocrypto
              ];
              checkInputs = with ocamlPackages; [
                ounit
              ];
              doCheck = true;
            };
        };

        packages = forAllSystems self.overlay;

        defaultPackage = forAllSystems (system: (import nixpkgs {
          inherit system;
          overlays = [ self.overlay nix.overlay ];
        }).ocaml-urps);

        checks = forAllSystems (system: {
          build = self.defaultPackage.${system};
          test = self.defaultPackage.${system} // {
            doCheck = true;
          };
        });
      };
}

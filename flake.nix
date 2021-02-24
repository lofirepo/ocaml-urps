{
  description = "URPS: Uniform Random Peer Sampler";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux" "aarch64-linux" "armv7l-linux"
        "x86_64-darwin" "aarch64-darwin"
      ];
      supportedOcamlPackages = [
        "ocamlPackages_4_10"
        "ocamlPackages_4_11"
        "ocamlPackages_4_12"
      ];
      defaultOcamlPackages = "ocamlPackages_4_11";

      forAllOcamlPackages = nixpkgs.lib.genAttrs supportedOcamlPackages;
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor =
        forAllSystems (system:
          import nixpkgs {
            inherit system;
            overlays = [ self.overlay ];
          });
    in
      {
        overlay = final: prev:
          with final;
          let mkOcamlPackages = prevOcamlPackages:
                with prevOcamlPackages;
                let ocamlPackages =
                      {
                        inherit ocaml;
                        inherit findlib;
                        inherit ocamlbuild;
                        inherit opam-file-format;
                        inherit buildDunePackage;

                        urps =
                          buildDunePackage rec {
                            pname = "urps";
                            version = "0.0.1";
                            src = self;

                            useDune2 = true;
                            doCheck = true;

                            nativeBuildInputs = with ocamlPackages; [
                              odoc
                              ounit
                            ];
                            buildInputs = with ocamlPackages; [
                              nocrypto
                            ];
                          };
                      };
                in ocamlPackages;
          in
            let allOcamlPackages =
                  forAllOcamlPackages (ocamlPackages:
                    mkOcamlPackages ocaml-ng.${ocamlPackages}
                  );
            in
              allOcamlPackages // {
                ocamlPackages = allOcamlPackages.${defaultOcamlPackages};
              };

        packages =
          forAllSystems (system:
            forAllOcamlPackages (ocamlPackages:
              nixpkgsFor.${system}.${ocamlPackages}
            ));

        defaultPackage =
          forAllSystems (system:
            nixpkgsFor.${system}.ocamlPackages.urps
          );
      };
}

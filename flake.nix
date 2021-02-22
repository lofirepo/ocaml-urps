{
  description = "URPS: Uniform Random Peer Sampler";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/master";
  };

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.ocaml-urps =
      with import nixpkgs { system = "x86_64-linux"; };
      ocamlPackages.buildDunePackage rec {
        pname = "urps";
        version = "0.0.1";
        src = self;
        useDune2 = true;

        buildInputs = with pkgs.ocamlPackages; [
          nocrypto
        ];
        nativeBuildInputs = with pkgs.ocamlPackages; [
          odoc
          ounit
        ];
      };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.ocaml-urps;
  };
}

{
  description = "flake for fetching epg";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = rec {
          src = pkgs.fetchFromGitHub {
              owner = "iptv-org";
              repo = "epg";
              rev = "3d4ced9e8843e787fa685925500e02516fbbaa84";
              sha256 = "sha256-dSTSlv6fuUE1msppzDUFi3asX/7ar5cXYuJg40R8ric=";
            };
          script = site: pkgs.writeText "script.sh" ''
            #!/usr/bin/env nix-shell
            #! nix-shell -i bash --pure
            #! nix-shell -p bash nodejs python3 curl cacert
            #! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs/archive/40cffc01bc89548395103929e3ddb98b57d00e67.tar.gz


            # fetch epg

            temp_dir=$(mktemp -d)
            cd $temp_dir
            mkdir epg
            cp -r ${src}/* epg
            chmod +rw -R epg
            cd epg
            npm install
            npm run grab --- --site=${site}

            # post processing

            mkdir ../post
            mv guide.xml ../post/guide.xml
            cd ..
            cp -r ${./.}/* post
            chmod +rw -R post
            cd post
            npm install
            node fix.js
            cp guide_new.xml $1/guide.xml
          '';
          epg = bySite "web.magentatv.de";
          bySite = site: pkgs.stdenv.mkDerivation {
            pname = "epg";
            version = "2025.1";
            src = ./.;
            buildPhase = '''';
            installPhase = ''
              mkdir -p $out/bin
              cp ${script site} $out/bin/epg
              chmod +x $out/bin/epg
            '';
          };
        };
      }
    );
}

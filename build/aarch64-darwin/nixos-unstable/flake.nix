{
  description = "A Nix flake for Gaigen 2.5";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };
    gaigen-sources = {
      url = "https://sourceforge.net/projects/g25/files/2.5.2/g25-2.5.2.tar.gz";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      gaigen-sources,
      ...
    }:
    let
      pkgs = nixpkgs.legacyPackages."aarch64-darwin";
      lib = nixpkgs.lib;
      pname = "gaigen";
      version = "2.5.2";
    in
    {
      packages."aarch64-darwin" = rec {

        default = gaigen;

        gaigen = pkgs.stdenv.mkDerivation (var: {
          name = pname + "-" + version;
          pname = pname;
          version = version;
          src = gaigen-sources;
          nativeBuildInputs = [ pkgs.gnused ];
          buildInputs = [ pkgs.mono ];

          buildPhase = ''
            # Intercept mixed-case and backslashed paths.
            export MONO_IOMAP=all

            # Fake doxygen.
            MOCK_DIR="$PWD/.nix-sandbox/bin"
            mkdir -p "$MOCK_DIR"
            echo 'exec true' > "$MOCK_DIR/doxygen"
            chmod +x "$MOCK_DIR/doxygen"
            export PATH="$MOCK_DIR:$PATH"

            # 1. Build g25
            (cd g25/vs2008 &&
                 xbuild g25.sln /p:Configuration=Release) ||
                exit 1

            # 2. Build g25_diff
            (cd g25_diff/vs2008 &&
                 xbuild g25_diff.csproj /p:Configuration=Release) ||
                exit 1

            # 3. Build g25_test_generator
            (cd g25_test_generator/vs2008 &&
                 xbuild g25_test_generator.csproj /p:Configuration=Release) ||
                exit 1
          '';

          installPhase = ''
            mkdir -p $out/lib/gaigen
            cp -R ./* $out/lib/gaigen

            mkdir -p $out/share/doc
            for f in g25_manual.txt g25_user_manual.{pdf,tex}; do
                cp manual/"$f" $out/share/doc
            done

            mkdir -p $out/share/man/man1
            for f in g25{.1,_test_generator.1}; do
                sed 's|/usr/share/g25|'$out'/share|' < g25/"$f" > $out/share/man/man1/"$f"
            done

            mkdir -p $out/bin
            printf '#!/usr/bin/env nix-shell\n' > $out/bin/g25
            printf '#!nix-shell -i zsh -p zsh mono\n' >> $out/bin/g25
            printf 'G25_HOME="%s{0:A:h}"/../lib/gaigen\n' '$' >> $out/bin/g25
            printf 'G25_COMMAND="%s{0##*/}"\n' '$' >> $out/bin/g25
            printf 'exec mono %s{G25_HOME}/%s{G25_COMMAND}/vs2008/bin/Release/%s{G25_COMMAND}.exe "%s{@}"\n' \
                   '$' '$' '$' '$' >> $out/bin/g25
            chmod +x $out/bin/g25
            for f in g25_copy_resource g25_diff g25_test_generator; do
                cp $out/bin/{g25,$f}
            done
          '';
        });
      };
    };
}

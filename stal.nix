{stdenvNoCC, makeWrapper, rakudo}:
stdenvNoCC.mkDerivation {
    name = "stal";
    buildInputs = [makeWrapper];
    phases = ["unpackPhase" "buildPhase" "installPhase"];
    unpackPhase = ''
        cp --recursive ${./bin} bin
        cp --recursive ${./lib} lib
    '';
    buildPhase = ''
        # TODO: Precompile the application.
    '';
    installPhase = ''
        mkdir --parents $out/bin $out/share
        cp --recursive bin lib $out/share
        makeWrapper ${rakudo}/bin/rakudo $out/bin/stalc \
            --set PERL6LIB $out/share/lib \
            --add-flags $out/share/bin/stalc.p6
    '';
}

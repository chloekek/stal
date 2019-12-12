let pkgs = import ./nix/pkgs.nix {}; in
pkgs.callPackage ./stal.nix {}

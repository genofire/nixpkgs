{ lib, stdenv
, fetchurl
, pkgs
, fixDarwinDylibNames
}:
stdenv.mkDerivation rec {
  pname = "build2-bootstrap";
  version = "0.13.0";
  src = fetchurl {
    url = "https://download.build2.org/${version}/build2-toolchain-${version}.tar.xz";
    sha256 = "01hmr5y8aa28qchwy9ci8x5q746flwxmlxarmy4w9zay9nmvryms";
  };
  patches = [
    # Pick up sysdirs from NIX_LDFLAGS
    ./nix-ldflags-sysdirs.patch
  ];

  sourceRoot = "build2-toolchain-${version}/build2";
  makefile = "bootstrap.gmake";
  enableParallelBuilding = true;

  setupHook = ./setup-hook.sh;

  strictDeps = true;

  propagatedBuildInputs = lib.optionals stdenv.targetPlatform.isDarwin [
    fixDarwinDylibNames
  ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck
    build2/b-boot --version
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -D build2/b-boot $out/bin/b
    runHook postInstall
  '';

  inherit (pkgs.build2) passthru;
}

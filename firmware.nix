{stdenv, fetchFromGitHub, autoPatchelfHook, zsa, qmk, python3, git, gcc-arm-embedded, pkgsCross, avrdude, dfu-programmer, dfu-util}:

let
  firmware = fetchFromGitHub {
    owner = "zsa";
    repo = "qmk_firmware";
    inherit (zsa) rev;
    fetchSubmodules = true;
    sha256 = "sha256-yqnsSDY6aouHh0FF+U9VqJSQGCEo7+WCjoSFRqkC1F8=";
  };

  kb = "moonlander";
  km = "default";
in
stdenv.mkDerivation {
  pname = "nobbz_ml";
  version = "1";

  buildInputs = [ autoPatchelfHook git qmk gcc-arm-embedded pkgsCross.avr.buildPackages.gcc8 avrdude dfu-programmer dfu-util ];

  src = firmware;

  dontAutoPatchelf = true;

  patchPhase = ''
    substituteInPlace bin/qmk \
      --replace "#!/usr/bin/env python3" "#!${python3}/bin/python"
  '';

  buildPhase = ''
    qmk setup -y
    qmk compile -kb ${kb} -km ${km}
  '';

  installPhase = ''
    cp ${kb}_${km}.bin $out
  '';
}
{
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  zsa,
  qmk,
  python3,
  git,
  gcc-arm-embedded,
  pkgsCross,
  avrdude,
  dfu-programmer,
  dfu-util,
}: let
  firmware = fetchFromGitHub {
    name = "zsa-firmware-${zsa.rev}-source";
    owner = "zsa";
    repo = "qmk_firmware";
    inherit (zsa) rev;
    fetchSubmodules = true;
    sha256 = "sha256-yqnsSDY6aouHh0FF+U9VqJSQGCEo7+WCjoSFRqkC1F8=";
  };

  kb = "moonlander";
  km = "nobbz";

  version = "BgPVO";

  firmwareSrc = ./firmware;
in
  stdenv.mkDerivation {
    name = "${kb}_${km}_${version}.bin";

    buildInputs = [git qmk gcc-arm-embedded pkgsCross.avr.buildPackages.gcc8 avrdude dfu-programmer dfu-util];

    srcs = [firmware firmwareSrc];
    sourceRoot = firmware.name;

    dontAutoPatchelf = true;

    unpackPhase = ''
      runHook preUnpack

      for s in $srcs; do
        dst=$(stripHash "$s")
        cp -rv "$s" "$dst"
        chmod -Rv +w $dst
      done

      runHook postUnpack
    '';

    patchPhase = ''
      substituteInPlace bin/qmk \
        --replace "#!/usr/bin/env python3" "#!${python3}/bin/python"
    '';

    configurePhase = ''
      mkdir -p keyboards/${kb}/keymaps
      cp -rv ../firmware keyboards/${kb}/keymaps/${km}
    '';

    buildPhase = ''
      qmk setup -y
      qmk compile -kb ${kb} -km ${km}
    '';

    installPhase = ''
      cp ${kb}_${km}.bin $out
    '';
  }

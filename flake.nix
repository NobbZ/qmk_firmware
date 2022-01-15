{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.zsa.url = "github:zsa/qmk_firmware/firmware20";
  inputs.zsa.flake = false;

  outputs = {self, nixpkgs, zsa, ... }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    devShell.x86_64-linux = pkgs.mkShell {
      packages = [ pkgs.qmk pkgs.gcc-arm-embedded pkgs.pkgsCross.avr.buildPackages.gcc8 pkgs.avrdude pkgs.dfu-programmer pkgs.dfu-util ];
    };

    packages.x86_64-linux.firmware = pkgs.callPackage ./firmware.nix { inherit zsa; };
  };
}
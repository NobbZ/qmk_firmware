{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  inputs.zsa.url = "github:zsa/qmk_firmware/firmware20";
  inputs.zsa.flake = false;

  outputs = {
    self,
    nixpkgs,
    zsa,
    ...
  }: let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    devShell.x86_64-linux = self.x86_64-linux.default; # For compatibility with nix 2.7 and older
    devShells.x86_64-linux.default = pkgs.mkShell {
      packages = [pkgs.wally-cli pkgs.qmk pkgs.gcc-arm-embedded pkgs.pkgsCross.avr.buildPackages.gcc8 pkgs.avrdude pkgs.dfu-programmer pkgs.dfu-util];
    };

    packages.x86_64-linux.firmware = pkgs.callPackage ./firmware.nix {inherit zsa;};
    packages.x86_64-linux.default = self.packages.x86_64-linux.firmware;

    apps.x86_64-linux.default = self.apps.x86_64-linux.push;
    apps.x86_64-linux.push.type = "app";
    apps.x86_64-linux.push.program = "${pkgs.writeShellScript "push" ''
      ${pkgs.wally-cli}/bin/wally-cli ${self.packages.x86_64-linux.firmware}
    ''}";
  };
}

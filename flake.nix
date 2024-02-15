{
  description = "eBPF Tutorial";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system: 
    let
      pkgs = import nixpkgs { inherit system; };
      cHelper = rec {
        buildInputs = with pkgs; [
          pkgsi686Linux.glibc
          llvm
          libbpf
        ];
        
        drv = { name }: pkgs.stdenv.mkDerivation {
          inherit system name buildInputs;
          version = "0.0.0";
          src = ./.;

          buildPhase = ''
            mkdir $out
            ${pkgs.clang}/bin/clang -O2 -Wall -target bpf -c c/${name}.c -o $out/${name}.o
          '';
        };
      };
    in
    {
      packages = {
        drop-arp = cHelper.drv { name = "drop-arp"; };
        drop-icmp = cHelper.drv { name = "drop-icmp"; };
        drop-tcp = cHelper.drv { name = "drop-tcp"; };
      };
      devShells.default = pkgs.mkShell {
        buildInputs = cHelper.buildInputs;
        nativeBuildInputs = with pkgs; [
          clang
          clang-tools
        ];
      };
    }
  );
}

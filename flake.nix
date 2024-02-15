{
  description = "eBPF Tutorial";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system: 
    let
      pkgs = nixpkgs.legacyPackages.${system};
      drv = { name }: pkgs.stdenv.mkDerivation {
          inherit system name;
          version = "0.0.0";
          src = ./.;

          buildInputs = with pkgs; [
            pkgsi686Linux.glibc
            llvm
          ];
          
          buildPhase = ''
            mkdir $out
            ${pkgs.clang}/bin/clang -O2 -Wall -target bpf -c ${name}.c -o $out/${name}.o
          '';
      };
    in
    {
      packages = {
        drop-arp = drv { name = "drop-arp"; };
        drop-icmp = drv { name = "drop-icmp"; };
        drop-tcp = drv { name = "drop-tcp"; };
      };
      devShells.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          pkgsi686Linux.glibc
          llvm
        ];
        nativeBuildInputs = with pkgs; [
          clang
          clang-tools

          libbpf
        ];
      };
    }
  );
}

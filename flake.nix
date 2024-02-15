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
        
        drv = { name, path }: pkgs.stdenv.mkDerivation {
          inherit system name buildInputs;
          version = "0.0.0";
          src = ./.;

          buildPhase = ''
            mkdir $out
            ${pkgs.clang}/bin/clang -O2 -Wall -target bpf -c ${path} -o $out/${name}.o
          '';
        };
      };
    in
    {
      packages = {
        drop-arp = cHelper.drv { name = "drop-arp"; path = "firewalling-with-bpf-xdp/drop-arp.c"; };
        drop-icmp = cHelper.drv { name = "drop-icmp"; path = "firewalling-with-bpf-xdp/drop-icmp.c"; };
        drop-tcp = cHelper.drv { name = "drop-tcp"; path = "firewalling-with-bpf-xdp/drop-tcp.c"; };
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

{
  description = "eBPF Tutorial";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { nixpkgs, flake-utils, ... }: flake-utils.lib.eachDefaultSystem (system: 
    let
      pkgs = nixpkgs.legacyPackages.${system};
      buildInputs = with pkgs; [
        pkgsi686Linux.glibc
        llvm
        libbpf
      ];
          
      clangBpfDerivation = { name }: pkgs.stdenv.mkDerivation {
          inherit system name buildInputs;
          version = "0.0.0";
          src = ./.;

          buildPhase = ''
            mkdir $out
            ${pkgs.clang}/bin/clang -O2 -Wall -target bpf -c c/${name}.c -o $out/${name}.o
          '';
      };
    in
    {
      packages = {
        drop-arp = clangBpfDerivation { name = "drop-arp"; };
        drop-icmp = clangBpfDerivation { name = "drop-icmp"; };
        drop-tcp = clangBpfDerivation { name = "drop-tcp"; };
      };
      devShells.default = pkgs.mkShell {
        inherit buildInputs;
        nativeBuildInputs = with pkgs; [
          clang
          clang-tools
        ];
      };
    }
  );
}

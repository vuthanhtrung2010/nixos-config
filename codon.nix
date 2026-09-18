{ pkgs, ... }:

let
  codonPkg = pkgs.stdenv.mkDerivation {
    pname = "codon";
    version = "0.20.2";

    src = pkgs.fetchurl {
        url = "https://github.com/exaloop/codon/releases/download/v0.20.2/codon-linux-x86_64.tar.gz";
        hash = "sha256-c548UvCLy33dICd7Y9cuEa4x1Oj9rimxxkWPjWXXeU0=";
    };

    nativeBuildInputs = [
        pkgs.autoPatchelfHook
    ];

    buildInputs = [
        pkgs.stdenv.cc.cc.lib
        pkgs.zlib
    ];

    sourceRoot = ".";

    dontBuild = true;

    installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp -r codon-deploy-linux-x86_64/. $out/

        runHook postInstall
    '';

    meta = with pkgs.lib; {
      homepage = "https://github.com/exaloop/codon";
      description = "A high-performance, zero-overhead, extensible Python compiler using LLVM";
      platforms = [ "x86_64-linux" ];
    };
  };
in
{
  # Automatically installs codon directly when this file is imported
  environment.systemPackages = [ codonPkg ];
}
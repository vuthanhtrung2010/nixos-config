
{ pkgs, ... }:

let
  pname = "orca";
  version = "1.4.200";

  src = pkgs.fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v1.4.200/orca-linux.AppImage";
    hash = "sha256-yC2d31MkMeDaUexdGJmg4xWqu453/ORezOf61HM/yWo=";
  };

  extracted = pkgs.appimageTools.extractType2 {
    inherit pname version src;
  };

  orca = pkgs.appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -Dm644 \
        ${extracted}/orca-ide.desktop \
        $out/share/applications/orca.desktop

      substituteInPlace $out/share/applications/orca.desktop \
        --replace-fail "Exec=AppRun %U" "Exec=orca %U"

      cp -r ${extracted}/usr/share/icons $out/share/
    '';
  };
in
{
  environment.systemPackages = [
    orca
  ];
}
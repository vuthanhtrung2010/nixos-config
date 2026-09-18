{ pkgs, ... }:

let
  pname = "orca-ide";
  version = "1.4.204";

  src = pkgs.fetchurl {
    url = "https://github.com/stablyai/orca/releases/download/v1.4.204/orca-linux.AppImage";
    hash = "sha256-DISBBX0lC80GKZIUvV4hQ5E3lkso5ozC6hdvmg68NVk=";
  };

  extracted = pkgs.appimageTools.extractType2 {
    inherit pname version src;
  };

  orca-ide = pkgs.appimageTools.wrapType2 {
    inherit pname version src;

    extraInstallCommands = ''
      install -Dm644 \
        ${extracted}/orca-ide.desktop \
        $out/share/applications/orca-ide.desktop

      substituteInPlace $out/share/applications/orca-ide.desktop \
        --replace-fail "Exec=AppRun %U" "Exec=orca-ide %U"

      cp -r ${extracted}/usr/share/icons $out/share/
    '';
  };
in
{
  environment.systemPackages = [
    orca-ide
  ];
}

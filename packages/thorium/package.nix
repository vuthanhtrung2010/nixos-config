{
  lib,
  stdenv,
  appimageTools,
  fetchurl,
  variant ? null,
}:
let
  hashes = builtins.fromJSON (builtins.readFile ./hashes.json);
  system = stdenv.hostPlatform.system;

  defaultVariant =
    if system == "x86_64-linux" then
      "avx2"
    else if system == "aarch64-linux" then
      "arm64"
    else
      throw "Unsupported Thorium platform: ${system}";

  selectedVariant = if variant != null then variant else defaultVariant;

  systemVariants =
    hashes.variants.${system}
      or (throw "Thorium does not support system: ${system}");

  variantData =
    systemVariants.${selectedVariant}
      or (throw "Thorium variant '${selectedVariant}' is not available for system '${system}'");

  pname = "thorium";
  version = hashes.version;

  src = fetchurl {
    url = variantData.url;
    hash = variantData.hash;
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    if [ -f "${appimageContents}/thorium-browser.desktop" ]; then
      install -m 444 -D "${appimageContents}/thorium-browser.desktop" "$out/share/applications/thorium-browser.desktop"
    elif [ -f "${appimageContents}/thorium.desktop" ]; then
      install -m 444 -D "${appimageContents}/thorium.desktop" "$out/share/applications/thorium-browser.desktop"
    fi

    if [ -f "${appimageContents}/thorium.png" ]; then
      install -m 444 -D "${appimageContents}/thorium.png" "$out/share/icons/hicolor/512x512/apps/thorium.png"
    fi

    for df in "$out"/share/applications/*.desktop; do
      [ -f "$df" ] || continue
      substituteInPlace "$df" \
        --replace-warn 'Exec=AppRun --no-sandbox %U' 'Exec=thorium %U' \
        --replace-warn 'Exec=AppRun %U' 'Exec=thorium %U' \
        --replace-warn 'Exec=thorium-browser' 'Exec=thorium'
    done
  '';

  meta = with lib; {
    description = "Compiler-optimized Chromium fork for maximum performance (${selectedVariant} build)";
    homepage = "https://thorium.rocks";
    changelog = "https://github.com/gz83/thorium/releases/tag/${hashes.tag}";
    license = licenses.bsd3;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "thorium";
  };
}

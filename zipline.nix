{ pkgs, ... }:

let
  ziplineScript = pkgs.writeShellScriptBin "zipline-screenshot" ''
    if [ -f /etc/nix-secrets/zipline-token ]; then
        Z_TOKEN=$(cat /etc/nix-secrets/zipline-token)
    else
        echo "Missing Zipline token!"
        exit 1
    fi

    ${pkgs.flameshot}/bin/flameshot gui -r > /tmp/screenshot.png
    if [ ! -s /tmp/screenshot.png ]; then
        exit 0
    fi

    url=$(${pkgs.curl}/bin/curl -s \
        -H "authorization: $Z_TOKEN" \
        https://cdn.trunghsgs.edu.vn/api/upload \
        -F file=@/tmp/screenshot.png \
        -H 'x-zipline-format: random' \
        -H 'x-zipline-original-name: true' |
        ${pkgs.jq}/bin/jq -r '.files[0].url // empty')

    if [ -z "$url" ]; then
        exit 1
    fi

    printf '%s' "$url" | ${pkgs.wl-clipboard}/bin/wl-copy
    ${pkgs.wl-clipboard}/bin/wl-copy --type image/png < /tmp/screenshot.png
  '';
in
{
  environment.systemPackages = [ ziplineScript ];
}

{
  inputs,
  pkgs,
  ...
}: {
  disabledModules = ["services/web-servers/rustfs.nix"];

  imports = [
    inputs.rustfs.nixosModules.default
  ];

  environment.systemPackages = [
    pkgs.rustfs
    pkgs.rustfs-cli
  ];

  services.rustfs = {
    enable = true;
    package = pkgs.rustfs;
    accessKeyFile = "/etc/nix-secrets/rustfs-access-key";
    secretKeyFile = "/etc/nix-secrets/rustfs-secret-key";
  };
}

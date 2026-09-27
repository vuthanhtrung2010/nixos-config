# Trung's NixOS config

To get started, clone the repo, `cd` into it then:

```bash
./rebuild.sh
# or: sudo nixos-rebuild switch --flake .#nixos --impure
```

To temporarily test changes from your local serpantinum development repo:

```bash
./rebuild.sh --local
# or: rebuild-local
# or: sudo nixos-rebuild switch --flake .#nixos --impure --override-input serpantinum /home/devtrung/orca/workspaces/serpantinum/fix-wallpaper-choosing
```

and yes you got the working system.

If you want it to work with yours, fork the repo & change the username `devtrung` to your username. Also you can remove sops-nix out and remove the ssh key copy.

NixOS on top.

When I can step into hanland?

# Secrets (for devtrung)

Make sure to put old private key at `~/.config/sops/age/keys.txt` and then rebuild

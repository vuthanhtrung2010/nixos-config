# Trung's NixOS config
To get started, clone the repo, `cd` into it then:
```
sudo nixos-rebuild switch --flake .#nixos --impure
```

and yes you got the working system.

If you want it to work with yours, fork the repo & change the username `devtrung` to your username. Also you can remove sops-nix out and remove the ssh key copy.

NixOS on top.

When I can step into hanland?

# Secrets (for devtrung)
Make sure to put old private key at `~/.config/sops/age/keys.txt` and then rebuild
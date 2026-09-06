{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    serpantinum.url = "github:ilyamiro/serpantinum";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    serpantinum,
    home-manager,
    sops-nix,
    ...
  }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit serpantinum;};
      modules = [
        ./configuration.nix

        serpantinum.nixosModules.default

        sops-nix.nixosModules.sops

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.extraSpecialArgs = {inherit serpantinum;};
          home-manager.users.devtrung = {pkgs, ...}: {
            home.stateVersion = "26.11";
            
            # Tell gtk & qt to use dark theme
            gtk = {
              enable = true;

              theme = {
                name = "Adwaita-dark";
                package = pkgs.gnome-themes-extra;
              };

              gtk3.extraConfig = {
                gtk-application-prefer-dark-theme = true;
              };

              gtk4.extraConfig = {
                gtk-application-prefer-dark-theme = true;
              };
            };

            qt = {
              enable = true;

              platformTheme.name = "gtk3";

              style = {
                name = "adwaita-dark";
                package = pkgs.adwaita-qt;
              };
            };

            dconf.settings = {
              "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
              };
            };

            imports = [
              serpantinum.homeManagerModules.default
              sops-nix.homeManagerModules.sops
              ./config-files.nix
              ./shell.nix
            ];

            sops = {
              defaultSopsFile = ./secrets/keys.yml;

              age.keyFile = "/home/devtrung/.config/sops/age/keys.txt";

              secrets.ssh_private_key = {
                path = "/home/devtrung/.ssh/id_ed25519";
                mode = "0600";
              };
            };

            programs.vscode = {
              enable = true;
              package = pkgs.vscode;
            };

            programs.neovim = {
              enable = true;
              defaultEditor = true;
              viAlias = true;
              vimAlias = true;

              initLua = ''
                -- Set Tab = 2 spaces
                vim.opt.tabstop = 2
                vim.opt.softtabstop = 2
                vim.opt.shiftwidth = 2
                vim.opt.expandtab = true

                -- Auto & Smart Indent
                vim.opt.autoindent = true
                vim.opt.smartindent = true

                -- Bật số dòng (dễ căn chỉnh code)
                vim.opt.number = true
                vim.opt.relativenumber = true
              '';
            };

            programs.git = {
              enable = true;

              settings = {
                user.email = "vuthanhtrungsuper@gmail.com";
                user.name = "devtrung";
              };

              signing = {
                format = "ssh";
                key = "/home/devtrung/.ssh/id_ed25519.pub";
                signByDefault = true;
              };
            };

            # Home env var
            home.sessionVariables = {
              SOPS_EDITOR = "nvim"; # Use vim editor for sops
            };

            programs.serpantinum = {
              enable = true;
              systemd.enable = true;

              settings = {
                wallpaperDir = "/home/devtrung/Pictures/Wallpapers";

                general = {
                  language = "en";
                  weatherUnit = "metric";
                  weatherInterval = 30;
                  avatarPath = "/home/devtrung/pfp.png";
                };

                bar = {
                  position = "top";
                  style = "fill";
                  width = 60;
                  workspaceCount = 10;
                  modules = {
                    left = [
                      "left" # quick settings
                      "workspaces"
                      "vis"
                    ];
                    center = ["time"];
                    right = [
                      "tray"
                      [
                        "weather"
                        "wifi"
                        "bt"
                        "vol"
                        "bat"
                      ]
                    ];
                  };
                };

                theme = {
                  fontFamily = "Adwaita Mono";
                  borderRadius = 12;
                  matugen = true;
                };
              };
            };
          };
        }
      ];
    };
  };
}

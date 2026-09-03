{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    serpantinum.url = "github:ilyamiro/serpantinum";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    serpantinum,
    home-manager,
    ...
  }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit serpantinum;};
      modules = [
        ./configuration.nix

        serpantinum.nixosModules.default

        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "bak";
          home-manager.extraSpecialArgs = {inherit serpantinum;};
          home-manager.users.devtrung = {pkgs, ...}: {
            home.stateVersion = "26.05";

            # Files copy
            home.fileOverlapResolution = "override";
            home.file."Pictures/Wallpapers" = {
              source = ./wallpapers;
              recursive = true;
            };
            home.file."pfp.png".source = ./pfp.png;

            # Config file copy
            xdg.configFile."hypr" = {
              source = "${serpantinum}/compositors/hyprland";
              recursive = true;
            };

            xdg.configFile."hypr/config/keybinds.lua".source =
              ./config/hypr/keybinds.lua;
            xdg.configFile."fastfetch" = {
              source = "${serpantinum}/config/fastfetch";
              recursive = true;
            };

            imports = [
              serpantinum.homeManagerModules.default
            ];

            programs.zsh = {
              enable = true;
              enableCompletion = true;
              autosuggestion.enable = true;
              syntaxHighlighting.enable = true;

              initContent = ''
                [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
                fastfetch
              '';

              oh-my-zsh = {
                enable = true;
                plugins = [
                  "git"
                  "sudo"
                  "history"
                ];
              };

              plugins = [
                {
                  name = "powerlevel10k";
                  src = pkgs.zsh-powerlevel10k;
                  file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
                }
              ];
            };

            programs.kitty = {
              enable = true;
              settings = {
                shell = "${pkgs.zsh}/bin/zsh";
              };
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

            programs.eza = {
              enable = true;
              icons = "auto";
              git = true;
              enableZshIntegration = true;
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
                  style = "solid";
                  width = 40;
                  workspaceCount = 10;
                  modules = {
                    left = ["workspaces"];
                    center = ["time"];
                    right = [
                      "tray"
                      [
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

{serpantinum, ...}: {
  home.fileOverlapResolution = "override";

  home.file."Pictures/Wallpapers" = {
    source = ./wallpapers;
    recursive = true;
  };
  home.file."pfp.png".source = ./pfp.png;

  xdg.configFile."hypr" = {
    source = "${serpantinum}/compositors/hyprland";
    recursive = true;
  };

  xdg.configFile."hypr/config/keybinds.lua".source =
    ./config/hypr/keybinds.lua;
  xdg.configFile."fastfetch" = {
    source = ./config/fastfetch;
    recursive = true;
  };

  home.file.".ssh/authorized_keys".source =
    ./config/ssh/authorized_keys;

  home.file.".ssh/config".source =
    ./config/ssh/config;

  home.file.".ssh/id_ed25519.pub".source =
    ./config/ssh/id_ed25519.pub;
}

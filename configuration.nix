# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
    ./zipline.nix
  ];

  nix.settings.substituters = [ "https://aseipp-nix-cache.global.ssl.fastly.net" ];

  # experimental (better UX)
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Is this a VM?
  _module.args.isProxmoxVM = builtins.elem "virtio_pci" (config.boot.initrd.availableKernelModules or []);

  # auto optimize disk space
  nix.settings.auto-optimise-store = true;

  # Disable sleep/hibernate for VM
  systemd.targets.sleep.enable = !config._module.args.isProxmoxVM;
  systemd.targets.suspend.enable = !config._module.args.isProxmoxVM;
  systemd.targets.hibernate.enable = !config._module.args.isProxmoxVM;
  systemd.targets.hybrid-sleep.enable = !config._module.args.isProxmoxVM;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 2; # keep at most 2 generation on systemd boot
  boot.kernelPackages = pkgs.linuxPackages; # LTS kernel, for latest kernel linuxPackages_latest
  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Bangkok";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "th_TH.UTF-8";
    LC_IDENTIFICATION = "th_TH.UTF-8";
    LC_MEASUREMENT = "th_TH.UTF-8";
    LC_MONETARY = "th_TH.UTF-8";
    LC_NAME = "th_TH.UTF-8";
    LC_NUMERIC = "th_TH.UTF-8";
    LC_PAPER = "th_TH.UTF-8";
    LC_TELEPHONE = "th_TH.UTF-8";
    LC_TIME = "th_TH.UTF-8";
  };

  # Fcitx5
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      addons = with pkgs; [
        fcitx5-lotus
        fcitx5-gtk
        kdePackages.fcitx5-qt
      ];
      waylandFrontend = true;
    };
  };

  # Fcitx5 lotus needs this proxy user
  users.users.uinput_proxy = {
    isSystemUser = true;
    group = "uinput_proxy";
    description = "Uinput proxy user for fcitx5-lotus";
  };
  users.groups.uinput_proxy = {};
  hardware.uinput.enable = true;

  systemd.packages = [pkgs.fcitx5-lotus];
  boot.kernelModules = ["uinput"]; # uinput must be loaded by default
  systemd.services."fcitx5-lotus-server@devtrung" = {
    wantedBy = ["multi-user.target"];
    overrideStrategy = "asDropin";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = false;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # Enable KDE Plasa 6
  #services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."devtrung" = {
    isNormalUser = true;
    description = "Vu Thanh Trung";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      kdePackages.kate
      #  thunderbird
    ];
  };

  programs = {
    zsh.enable = true;
    hyprland = {
      enable = true;
      withUWSM = true;
    };
    serpantinum.enable = true;
    obs-studio = {
      enable = true;
      enableVirtualCamera = true;
    };
    nix-ld.enable = true;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    appimage-run
    vim
    wget
    bind # nslookup, dig, etc
    kdePackages.dolphin
    _7zip-zstd
    fastfetch
    home-manager
    btop
    wl-clipboard
    (ungoogled-chromium.override {
      enableWideVine = true;
    })
    qt6.qtsvg
    vesktop
    #bambu-studio
    orca-slicer
    eza
    uv
    go
    gopls
    gotools
    flameshot
    alejandra
    grim
    slurp
    cliphist
    termius
  ];

  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      google-fonts
      rubik
      nerd-fonts.meslo-lg
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  virtualisation.docker.enable = true;

  # Allow apps to communicate with the keyring
  security.polkit.enable = true;

  # let's write it shorter
  services = {
    openssh.enable = true;
    tailscale.enable = true;
    gnome.gnome-keyring.enable = true;
    qemuGuest.enable = config._module.args.isProxmoxVM;
    spice-vdagentd.enable = config._module.args.isProxmoxVM;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "26.11"; # Did you read the comment?
}

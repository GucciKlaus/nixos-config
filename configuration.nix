{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./backup-rsync.nix
  ];

  # =========================================================
  # Boot
  # =========================================================
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.systemd.enable = true;
  boot.extraModulePackages = [ config.boot.kernelPackages.evdi ];
  boot.initrd.kernelModules = [ "evdi" ];
  boot.kernelParams = [
    "random.trust_cpu=on"
    "lockdown=confidentiality"
    "nvidia-drm.modeset=1"
    "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
    "nvidia.NVreg_TemporaryFilePath=/run"
    "nvidia-drm.fbdev=1"
  ];

  # Optional Hardening / Sysctl
  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.conf.all.accept_source_route" = 0;
  };

  boot.tmp.useTmpfs = true;

  # =========================================================
  # System basics
  # =========================================================
  networking.hostName = "echo";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Vienna";
  i18n.defaultLocale = "en_US.UTF-8";

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # =========================================================
  # Desktop / GNOME
  # =========================================================
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;
  services.xserver.enableCtrlAltBackspace = true;
  #X11 no longer supported
  
  services.xserver.xkb = {
    layout = "de";
    variant = "";
    options = "caps:escape,eurosign:e";
  };

  environment.gnome.excludePackages = with pkgs; [
    gnome-software

    epiphany
    geary
    evolution
    evolution-data-server
    gnome-contacts
    gnome-calendar

    yelp
    gnome-tour

    gnome-music
    decibels
    papers
    snapshot
    showtime
    totem
    cheese
    evince
    loupe
    eog
    gnome-photos
    seahorse

    gnome-connections
    gnome-characters
    gnome-font-viewer
    gnome-text-editor
    simple-scan

    gnome-maps
    gnome-weather
    gnome-clocks
    gnome-notes

    tali
    iagno
    hitori
    atomix
  ];

  # =========================================================
  # Audio / Power / Randomness
  # =========================================================
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  security.rtkit.enable = true;
  services.power-profiles-daemon.enable = true;

  services.haveged.enable = true;
  #security.audit.enable = true;

  zramSwap.enable = true;

  # =========================================================
  # Firewall / SSH
  # =========================================================
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];
  networking.firewall.logRefusedConnections = true;

  services.openssh.enable = true;

  services.tailscale.enable = true;
  # =========================================================
  # Users
  # =========================================================
  users.users.klaus = {
    isNormalUser = true;
    home = "/home/klaus";
    createHome = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "wireshark"
      "docker"
      "libvirtd"
      "vboxusers"
    ];
  };

  # =========================================================
  # Filesystems / Swap
  # =========================================================
  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/29a46871-06c2-4f1a-89c8-fa93f2c93453";
    fsType = "ext4";
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 16384;
    }
  ];

  # =========================================================
  # Graphics / NVIDIA / DisplayLink
  # =========================================================
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = ["nvidia" "displaylink"];
  systemd.services.dlm.wantedBy = ["multi-user.target" ];

  hardware.nvidia = {
#    package = config.boot.kernelPackages.nvidiaPackages.mkDriver{
#      version = "595.58.03";
#      sha256_64bit = "sha256-jA1Plnt5MsSrVxQnKu6BAzkrCnAskq+lVRdtNiBYKfk=";
#      openSha256 = "sha256-6LvJyT0cMXGS290Dh8hd9rc+nYZqBzDIlItOFk8S4n8=";
#      settingsSha256 = "sha256-2vLF5Evl2D6tRQJo0uUyY3tpWqjvJQ0/Rpxan3NOD3c=";

#      usePersistenced = false;
#     };
      
    modesetting.enable = true;
    nvidiaSettings = true;
    open = true;

    powerManagement.enable = false;
    powerManagement.finegrained = true;

    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;

      intelBusId = "PCI:0@0:2:0";
      nvidiaBusId = "PCI:1@0:0:0";
    };
  };

  # =========================================================
  # Steam
  # =========================================================
  programs.steam.enable = true;

  # =========================================================
  # Virtualization
  # =========================================================
  virtualisation.docker.enable = true;
  systemd.services.docker.wantedBy = lib.mkForce [ ];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  programs.dconf.enable = true;
  # ========================================================
  # Terminal
  # ========================================================
  programs.dconf.profiles.user.databases = [
  {
    settings = {
      "org/gnome/terminal/legacy/profiles:" = {
        default = "b1dcc9dd-5262-4d8d-a863-c897e6d979b9";
        list = [ "b1dcc9dd-5262-4d8d-a863-c897e6d979b9" ];
      };

      "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
        visible-name = "Default";
        use-theme-colors = false;
        use-theme-background = false;
        foreground-color = "rgb(220,220,220)";
        background-color = "rgb(30,30,30)";
        bold-color-same-as-fg = true;
        use-system-font = false;
        font = "JetBrains Mono 12";
        scrollback-unlimited = true;
        audible-bell = false;
      };
    };
  }
  ];

  environment.extraInit = ''
    export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
  '';

  # =========================================================
  # Security / Network tools
  # =========================================================
  programs.wireshark.enable = true;

  # =========================================================
  # Packages
  # =========================================================
  environment.systemPackages = with pkgs; [
    firefox
    brave
    thunderbird
    keepassxc
    protonvpn-gui
    git
    vscode
    neovim
    wget
    curl
    pciutils
    tor-browser
    discord
    spotify
    texstudio
    texliveFull
    anydesk
    displaylink
    tree
    libreoffice
    heroic
    super-productivity

    gcc
    cmake
    lldb
    clang
    gnumake
    libnl
    pkg-config
    

    python3
    python3Packages.pip
    jupyter-all

    jetbrains.idea-community
    go
    jdk21
    rpi-imager

    nmap
    arp-scan
    naabu
    wireshark
    tcpdump
    inetutils
    traceroute
    mtr
    bind
    openssl
    gnupg
    wireguard-tools
    socat
    netcat-openbsd
    dig
    net-tools
    tailscale
    rsync

    strace
    ltrace
    gdb
    radare2
    ghidra
    binutils
    file
    ripgrep
    jq
    obs-studio
    nasm

    docker-compose

    btop
    powertop
    iotop
    mesa-demos
  ];

  environment.variables.PATH = [ "$HOME/go/bin" ];

  system.stateVersion = "25.11";
}

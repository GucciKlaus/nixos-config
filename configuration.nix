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
  #  "lockdown=confidentiality"
  #  "nvidia-drm.modeset=1"
   # "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
   # "nvidia.NVreg_TemporaryFilePath=/run"
   # "nvidia-drm.fbdev=1"
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

  services.xserver.displayManager.lightdm.enable = true;

  services.xserver.desktopManager.xfce.enable = true;
  #services.xserver.displayManager.startx.enable = true;

  services.xserver.displayManager.defaultSession = "xfce";


  services.xserver.enableCtrlAltBackspace = true;
  #X11 no longer supported
  
  services.xserver.xkb = {
    layout = "de";
    variant = "";
    options = "caps:escape,eurosign:e";
  };

 #services.gnome.core-apps.enable = false;
 #services.gnome.core-developer-tools.enable = false;
 #services.gnome.games.enable = false;

  # =========================================================
  # Audio / Power / Randomness
  # =========================================================
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  security.rtkit.enable = true;
  #services.power-profiles-daemon.enable = true;

  services.haveged.enable = true;
  #security.audit.enable = true;

  zramSwap.enable = true;

  # =========================================================
  # Firewall / SSH
  # =========================================================
  networking.firewall = {
  enable = true;
  allowPing = false;
  allowedTCPPorts = [ ];
  logRefusedConnections = true;
  };
  
  services.openssh.enable = false;

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
  #systemd.services.dlm.wantedBy = ["multi-user.target" ];

  boot.blacklistedKernelModules = [
  "nouveau"
  ];

  hardware.nvidia = {
      
    modesetting.enable = true;
    nvidiaSettings = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;

    #powerManagement.enable = true;
    #powerManagement.finegrained = false;

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
  # systemd.services.docker.wantedBy = lib.mkForce [ ];

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;

  #programs.dconf.enable = true;
  

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
    proton-vpn
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
    tree
    libreoffice
    heroic
    imhex
    mattermost-desktop
    #nautilus
    xterm
    xclip
    zip
    unzip
    
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

    jetbrains.idea
    jdk21
    rpi-imager

    imagemagick
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


  system.stateVersion = "25.11";
}

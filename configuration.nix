{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./backup-rsync.nix
  ];

  # =========================================================
  # Boot
  # =========================================================
  boot.loader.systemd-boot.enable = false;
  boot.loader.efi = {
  canTouchEfiVariables = true;
  efiSysMountPoint = "/boot";
  };
  boot.initrd.systemd.enable = true;
  boot.extraModulePackages = [ config.boot.kernelPackages.evdi ];
  boot.initrd.kernelModules = [ "evdi" ];
  boot.kernelParams = [
    "random.trust_cpu=on"
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

  
  boot.loader.grub = {
   enable = true;
   efiSupport = true;
   devices = [ "nodev" ];
   useOSProber = true;
   configurationLimit = 20;
   theme = "/boot/grub/themes/dedsec/base/1440p";
  };

  
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

   services.xserver.enable = true;

  # =========================================================
  # Desktop / KDE
  # =========================================================

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = true;
  services.desktopManager.plasma6.enable = true;

  services.displayManager.defaultSession = "plasma";

  services.xserver.enableCtrlAltBackspace = true;
  
  
  services.xserver.xkb = {
    layout = "de";
    variant = "";
    options = "caps:escape,eurosign:e";
  };

 
  # =========================================================
  # Audio / Power / Randomness
  # =========================================================
  services.pipewire = {
  enable = true;
  alsa.enable = true;
  alsa.support32Bit = true;
  pulse.enable = true;
  wireplumber.enable = true;
  };

  security.rtkit.enable = true;
  services.power-profiles-daemon.enable = true;

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
  # AntiVirus
  # =========================================================

  services.clamav = {
  daemon.enable = true;
  updater.enable = true;

  scanner = {
    enable = true;
    interval = "weekly";
    scanDirectories = [
      "/home"
      "/tmp"
      "/var/tmp"
    ];
  };
  };  

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
      "kvm"
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

  boot.blacklistedKernelModules = [
  "nouveau"
  ];

  hardware.nvidia = {
      
    modesetting.enable = true;
    nvidiaSettings = true;
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.production;

    powerManagement.enable = true;
    powerManagement.finegrained = false;

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
  virtualisation.libvirtd.enable = true;

  programs.virt-manager.enable = true;
  
  nixpkgs.config.permittedInsecurePackages = [
                "electron-39.8.10"
              ];
 
  # =========================================================
  # Security / Network tools
  # =========================================================
  programs.wireshark.enable = true;

  # =========================================================
  # Packages
  # =========================================================
  environment.systemPackages = with pkgs; [
    brave
    thunderbird
    bitwarden-desktop
    proton-vpn
    qemu
    OVMF
    git
    vscode
    wget
    curl
    pciutils
    tor-browser
    discord
    spotify
    texliveFull
    anydesk
    tree
    libreoffice
    xournalpp
    whatsapp-electron
    poppler-utils
    heroic
    imhex
    mattermost-desktop
    qalculate-qt
    xterm
    xclip
    zip
    unzip
    anki
    
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
    nix-index

    strace
    ltrace
    gdb
    radare2
    ghidra
    binutils
    file
    ripgrep
    jq
    nasm

    docker-compose

    btop
    powertop
    iotop
    mesa-demos
    clamav
    lynis
  ];


  system.stateVersion = "25.11";
}

{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "echo";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Vienna";
  i18n.defaultLocale = "de_AT.UTF-8";

  nixpkgs.config.allowUnfree = true;

  # X11 + GNOME
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  services.xserver.xkb = {
    layout = "de";
    variant = "";
    options = "caps:escape,eurosign:e";
  };


  # Sound
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  security.rtkit.enable = true;

  #SWAP
  swapDevices = [{
  device = "/swapfile";
  size = 16384; # 16GB (BeamNG)
  }];

  # SSH
  services.openssh.enable = true;
  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ ];

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

  fileSystems."/data" = {
    device = "/dev/disk/by-uuid/29a46871-06c2-4f1a-89c8-fa93f2c93453";
    fsType = "ext4";
  };

  # Steam
  programs.steam.enable = true;

  # Graphics / 32-bit (für Steam/Proton)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # NVIDIA (RTX 3060 Laptop)
  services.xserver.videoDrivers = [ "nvidia" "displaylink"];

  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;

    powerManagement.enable = true;

  prime = {
    offload.enable = true;
    offload.enableOffloadCmd = true;

    intelBusId = "PCI:0:2:0";
    nvidiaBusId = "PCI:1:0:0";
   };
 };

 services.xserver.enableCtrlAltBackspace = true;


 boot.kernelParams = [
   "nvidia-drm.modeset=1"
   "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
 ];

  #Virtualisierung
  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  #Fucking VBox
  environment.extraInit = ''export XDG_DATA_DIRS="$XDG_DATA_DIRS:${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"'';
  programs.dconf.enable = true;


  # Docker (für Labs/Tools/Container)
  virtualisation.docker.enable = true;

  # Wireshark (setzt Group/Capabilities sauber)
  programs.wireshark.enable = true;

  environment.systemPackages = with pkgs; [
    # Daily
    firefox
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
    # Dev / Build
    gcc
    cmake
    lldb
    clang
    gnumake
    #Python
    python3
    python3Packages.pip
    jupyter-all
    #Dev
    jetbrains.idea-community
    go
    jdk21
    rpi-imager
    # Cybersec / Net
    nmap
    arp-scan
    naabu
    httpx
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
    # Forensics / Reverse / Debug
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
   #docker
   docker-compose

];

#Remove Gnome Features
environment.gnome.excludePackages = with pkgs; [

  # App Store
  gnome-software

  # Browser / Mail / Kontakte / Kalender
  epiphany
  geary
  evolution
  evolution-data-server
  gnome-contacts
  gnome-calendar

  # Hilfe / Tour
  yelp
  gnome-tour

  # Audio / Video / Kamera / Dokumente / Bilder
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

  # Remote / Tools / Editor
  gnome-connections
  gnome-characters
  gnome-font-viewer
  gnome-text-editor
  simple-scan

  # Maps / Weather / Clocks / Notes
  gnome-maps
  gnome-weather
  gnome-clocks
  gnome-notes

  # GNOME Games
  tali
  iagno
  hitori
  atomix
];


  system.stateVersion = "25.11";
}


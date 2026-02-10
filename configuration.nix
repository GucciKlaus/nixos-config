{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
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

  # SSH (praktisch für Homelab/Raspi)
  services.openssh.enable = true;

  users.users.klaus = {
    isNormalUser = true;
    home = "/home/klaus";
    createHome = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "wireshark"
      "docker"
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
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;

    # Optional (nur wenn Hybrid/Optimus):
    # prime = {
    #   offload.enable = true;
    #   offload.enableOffloadCmd = true;
    #   intelBusId = "PCI:0:2:0";
    #   nvidiaBusId = "PCI:1:0:0";
    # };
  };

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
    # Dev / Build
    gcc
    cmake
    lldb
    clang
    gnumake
    python3
    python3Packages.pip
    jetbrains.idea-community
    # Cybersec / Net
    nmap
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
    
   #docker
   docker-compose
  ];

  system.stateVersion = "25.11";
}

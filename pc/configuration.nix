{ config, lib, pkgs, ... }:

{  
  #-------------------- NIX --------------------#
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };
  #---------------------------------------------#

  #------------------ IMPORTS -------------------#
 
  imports = [
    ../home/modules/gamemode.nix
    ../home/modules/postgresql.nix
    ../home/modules/localsend.nix
    ../home/modules/docker.nix
  ];
  #----------------------------------------------#
  
  #-------------------- BOOT --------------------#
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  #----------------------------------------------#


  #-------------------- SYSTEM --------------------#
  networking.hostName = "nix-Os";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Mexico_City";

  zramSwap.enable = true;

  services.fstrim.enable = true;
  services.fwupd.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  services.gvfs.enable = true;

  programs.nix-ld.enable = true;
  #------------------------------------------------#


  #-------------------- NVIDIA --------------------#
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    nvidiaSettings = true;
  };
  #------------------------------------------------#


  #-------------------- HYPRLAND --------------------#
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };
  #--------------------------------------------------#


  #-------------------- WAYLAND --------------------#
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };
  #-------------------------------------------------#


  #-------------------- AUDIO --------------------#
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;

    pulse.enable = true;
  };
  #-----------------------------------------------#


  #-------------------- USERS --------------------#
  users.users.nonename = {
    isNormalUser = true;

    extraGroups = [
      "wheel"
      "audio"
      "video"
      "gamemode"
    ];
  };
  #-----------------------------------------------#


  #-------------------- SSH / FIREWALL --------------------#
  services.openssh = {
    enable = true;
    openFirewall = true;
  
    settings = {
      PermitRootLogin = "no";
    };
  };
  
  networking.firewall.enable = true;
  #--------------------------------------------------------#


  #-------------------- PACKAGES --------------------#
  environment.systemPackages = with pkgs; [
    wget
    git
    tree
    wev
    htop
    grim
    slurp
    wl-clipboard
    smartmontools
    hdparm
    iotop
    mangohud
    uv
  ];

  nixpkgs.config.allowUnfree = true;

  #--------------------------------------------------#


  #-------------------- FONTS --------------------#
  fonts.packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      noto-fonts
      noto-fonts-color-emoji
    ];
  
    fonts.fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "Noto Sans" ];
      emoji = [ "Noto Color Emoji" ];
    };
  #-----------------------------------------------#

  #--------------------- STORAGE --------------------#
  fileSystems."/home/nonename/storage" = {
    device = "/dev/disk/by-uuid/eefa7d10-03bd-431b-81d6-f53d71948feb";
    fsType = "ext4";
  };

  


  system.stateVersion = "26.05";
}

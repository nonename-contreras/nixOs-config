{ config, pkgs, ... }:

{
  imports = [ 
    ./modules/apps.nix
    ./modules/fuzzel.nix
    ./modules/hyprland.nix
    ./modules/yazi.nix
    ./modules/bash.nix
    ./modules/kitty.nix
    ./modules/quickshell.nix
    ./modules/clipboard.nix
    ./modules/mangohud.nix
    ./modules/proton-gen-bin.nix
    ./modules/background-apps.nix
    ./modules/gamescope.nix
    ./modules/vscode.nix
    ./modules/cursor.nix
];

  home.username = "nonename";
  home.homeDirectory = "/home/nonename";

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}

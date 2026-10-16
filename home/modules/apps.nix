{ pkgs, ... }:

{  
  home.packages = with pkgs; [
    micro
    brave
    steam
    discord
    chromium
    unrar
    (retroarch.withCores (cores: with cores; [
        beetle-psx-hw
      ]))

    fastfetch
    kdePackages.dolphin
    fuzzel
    playerctl
    brightnessctl
    jdk17
  ];

  xdg.desktopEntries.netflix = {
    name = "Netflix";
    genericName = "Netflix";
    comment = "Watch Netflix";
    exec = "${pkgs.brave}/bin/brave --app=https://www.netflix.com";
    terminal = false;

    categories = [
      "AudioVideo"
      "Video"
    ];
  };
}

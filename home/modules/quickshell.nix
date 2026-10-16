{ ... }:

let
  quickshellConfig = ./quickshell;
in
{
  programs.quickshell = {
    enable = true;

    configs.main = quickshellConfig;
    activeConfig = "main";

    systemd.enable = true;
  };
}

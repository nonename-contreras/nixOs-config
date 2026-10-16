{ pkgs, ... }:

{

  home.packages = with pkgs; [
    blesh
  ];

  programs.bash = {
    enable = true;
#-------------------- ALIAS -------------------#
    shellAliases = {
      ch = "nix flake check";
      r = "sudo nixos-rebuild switch --flake ~/nixos-config#nonename";
      h = "cd ~/nixos-config";
      c = "clear && printf '\e[3J'";
      rq = "systemctl --user restart quickshell";
      deadge = "poweroff";
    };
#----------------------------------------------#

#-------------------- COLOR TERMINAL NAME  -------------------#
    initExtra = ''
      PS1='\[\e[36m\] nonename-contreras \[\e[38;5;208m\]\w \[\e[0m\]󰆍 '

      source ${pkgs.blesh}/share/blesh/ble.sh

      bleopt complete_auto_complete=
      bleopt complete_auto_history=

      ble-face -s command_alias fg=cyan,bold
    '';
  };
}

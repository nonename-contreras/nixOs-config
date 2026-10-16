{ pkgs, ... }:

{
  home.file.".local/share/Steam/compatibilitytools.d/proton-ge".source =
    "${pkgs.proton-ge-bin.steamcompattool}";
}

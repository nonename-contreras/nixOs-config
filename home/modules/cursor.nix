{ pkgs, ... }:

let
  cursorName = "Cyberpunk-Neon";

  # -> Empaqueta el tema local para Home Manager.
  cyberpunkCursor = pkgs.runCommand "cyberpunk-neon-cursors" { } ''
    mkdir -p "$out/share/icons/${cursorName}"

    cp -a "${../cursors/Cyberpunk-Neon}/." \
      "$out/share/icons/${cursorName}/"
  '';

in
{
  home.pointerCursor = {
    enable = true;
    package = cyberpunkCursor;
    name = cursorName;
    size = 48;

    gtk.enable = true;
    x11.enable = true;
  };

  # -> Usa el formato XCursor para el escritorio.
  home.sessionVariables = {
    XCURSOR_THEME = cursorName;
    XCURSOR_SIZE = "48";
  };

  wayland.windowManager.hyprland.settings.env = [
    {
      _args = [ "XCURSOR_THEME" cursorName ];
    }
    {
      _args = [ "XCURSOR_SIZE" "32" ];
    }
  ];
}

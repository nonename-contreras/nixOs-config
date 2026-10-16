{ ... }:

{
  programs.fuzzel = {
    enable = true;

    settings = {
      main = {
        terminal = "kitty";
        layer = "overlay";

        width = 40;
        horizontal-pad = 20;
        vertical-pad = 12;
        inner-pad = 20;

        icons-enabled = true;
        lines = 8;
      };
  
      border = {
        width = 2;
        radius = 12;
      };
    };
  };
}

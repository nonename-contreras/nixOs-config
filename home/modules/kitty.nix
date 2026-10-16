{ ... }:

{
  programs.kitty = {
    enable = true;

    settings = {
      background = "#0d1117";
      foreground = "#e6edf3";

      background_opacity = "0.55";

      cursor = "#c9d1d9";
      selection_background = "#264f78";
      selection_foreground = "#ffffff";

      active_border_color = "#58a6ff";
      inactive_border_color = "#30363d";

      tab_bar_background = "#0d1117";
      active_tab_background = "#161b22";
      active_tab_foreground = "#f0f6fc";
      inactive_tab_background = "#0d1117";
      inactive_tab_foreground = "#8b949e";

      window_padding_width = 8;
      confirm_os_window_close = 0;
    };
  };
}

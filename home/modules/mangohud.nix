{ ... }:

{
  programs.mangohud = {
    enable = true;

    settings = {
      fps = true;
      frametime = true;

      gpu_stats = true;
      gpu_temp = true;
      gpu_mem = true;

      cpu_stats = true;
      cpu_temp = true;

      ram = true;
      vram = true;

      output_folder = "/home/nonename/mangohud-logs";

      toggle_logging = "Shift_L+F2";
    };
  };
}

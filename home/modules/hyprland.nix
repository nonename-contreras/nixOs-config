{ lib, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;

    package = null;
    portalPackage = null;

    settings = {

      # ============================================================
      # MONITORS
      # ============================================================

      monitor = [
        {
          output = "DP-1";
          mode = "1360x768@60";
          position = "0x0";
          scale = "1";
        }

        {
          output = "HDMI-A-1";
          mode = "1360x768@60";
          position = "1360x0";
          scale = "1";
        }
      ];


      # ============================================================
      # ENVIRONMENT
      # ============================================================


      # ============================================================
      # AUTOSTART
      # ============================================================

      on = [
        {
          _args = [
            "hyprland.start"
            (lib.generators.mkLuaInline ''
              function()
                hl.exec_cmd("/run/wrappers/bin/gnome-keyring-daemon --start --components=secrets")
              end
            '')
          ];
        }
      ];

      # ============================================================
      # GENERAL CONFIGURATION
      # ============================================================

      config = {

        # -------------------- GENERAL --------------------

        general = {
          gaps_in = 0;
          gaps_out = 0;
          border_size = 1;

          col = {
            active_border = "rgba(33ccffee)";
            inactive_border = "rgba(595959aa)";
          };

          resize_on_border = false;
          allow_tearing = false;
          layout = "dwindle";
        };


        # -------------------- DECORATION --------------------

        decoration = {
          rounding = 10;
          rounding_power = 2;

          active_opacity = 1.0;
          inactive_opacity = 0.90;

          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };

          blur = {
            enabled = true;
            size = 3;
            passes = 1;
            vibrancy = 0.1696;
          };
        };


        # -------------------- ANIMATIONS --------------------

        animations = {
          enabled = true;
        };


        # -------------------- LAYOUTS --------------------

        dwindle = {
          preserve_split = true;
        };

        master = {
          new_status = "master";
        };

        scrolling = {
          fullscreen_on_one_column = true;
        };


        # -------------------- MISC --------------------

        misc = {
          force_default_wallpaper = -1;
          disable_hyprland_logo = false;
        };


        # -------------------- INPUT --------------------

        input = {
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
          kb_options = "";
          kb_rules = "";

          follow_mouse = 1;
          sensitivity = 0;

          touchpad = {
            natural_scroll = false;
          };
        };
      };


      # ============================================================
      # GESTURES
      # ============================================================

      gesture = [
        {
          fingers = 3;
          direction = "horizontal";
          action = "workspace";
        }
      ];


      # ============================================================
      # MAIN MODIFIER
      # ============================================================

      mainMod = {
        _var = "SUPER";
      };


      # ============================================================
      # KEYBINDS
      # ============================================================

      bind = [

        # -------------------- PROGRAMS --------------------

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + Q\"")
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"kitty\")")
          ];
        }

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + C\"")
            (lib.generators.mkLuaInline "hl.dsp.window.close()")
          ];
        }

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + M\"")
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'\")")
          ];
        }

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + E\"")
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"dolphin\")")
          ];
        }

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + V\"")
            (lib.generators.mkLuaInline "hl.dsp.window.float({ action = \"toggle\" })")
          ];
        }

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + R\"")
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"fuzzel\")")
          ];
        }

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + P\"")
            (lib.generators.mkLuaInline "hl.dsp.window.pseudo()")
          ];
        }

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + J\"")
            (lib.generators.mkLuaInline "hl.dsp.layout(\"togglesplit\")")
          ];
        }


        # -------------------- FOCUS --------------------

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + left\"")
            (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"left\" })")
          ];
        }

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + right\"")
            (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"right\" })")
          ];
        }

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + up\"")
            (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"up\" })")
          ];
        }

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + down\"")
            (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"down\" })")
          ];
        }


        # -------------------- SPECIAL WORKSPACE --------------------

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + S\"")
            (lib.generators.mkLuaInline "hl.dsp.workspace.toggle_special(\"magic\")")
          ];
        }

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + SHIFT + S\"")
            (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = \"special:magic\" })")
          ];
        }


        # -------------------- WORKSPACE MOUSE WHEEL --------------------

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + mouse_down\"")
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"e+1\" })")
          ];
        }

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + mouse_up\"")
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"e-1\" })")
          ];
        }


        # -------------------- MOUSE --------------------

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + mouse:272\"")
            (lib.generators.mkLuaInline "hl.dsp.window.drag()")
            {
              mouse = true;
            }
          ];
        }

        {
          _args = [
            (lib.generators.mkLuaInline "mainMod .. \" + mouse:273\"")
            (lib.generators.mkLuaInline "hl.dsp.window.resize()")
            {
              mouse = true;
            }
          ];
        }


        # -------------------- SCREENSHOT --------------------

        {
          _args = [
            "Print"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"bash -lc 'mkdir -p \\\"$HOME/Pictures/Screenshots\\\"; region=$(slurp) || exit 0; file=\\\"$HOME/Pictures/Screenshots/screenshot_$(date +%Y-%m-%d_%H-%M-%S).png\\\"; grim -g \\\"$region\\\" \\\"$file\\\" && wl-copy < \\\"$file\\\"'\")")
          ];
        }


        # -------------------- VOLUME --------------------

        {
          _args = [
            "XF86AudioRaiseVolume"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+\")")
            {
              locked = true;
              repeating = true;
            }
          ];
        }

        {
          _args = [
            "XF86AudioLowerVolume"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-\")")
            {
              locked = true;
              repeating = true;
            }
          ];
        }

        {
          _args = [
            "XF86AudioMute"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle\")")
            {
              locked = true;
              repeating = true;
            }
          ];
        }

        {
          _args = [
            "XF86AudioMicMute"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle\")")
            {
              locked = true;
              repeating = true;
            }
          ];
        }


        # -------------------- BRIGHTNESS --------------------

        {
          _args = [
            "XF86MonBrightnessUp"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"brightnessctl -e4 -n2 set 5%+\")")
            {
              locked = true;
              repeating = true;
            }
          ];
        }

        {
          _args = [
            "XF86MonBrightnessDown"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"brightnessctl -e4 -n2 set 5%-\")")
            {
              locked = true;
              repeating = true;
            }
          ];
        }


        # -------------------- MEDIA --------------------

        {
          _args = [
            "XF86AudioNext"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl next\")")
            {
              locked = true;
            }
          ];
        }

        {
          _args = [
            "XF86AudioPause"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl play-pause\")")
            {
              locked = true;
            }
          ];
        }

        {
          _args = [
            "XF86AudioPlay"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl play-pause\")")
            {
              locked = true;
            }
          ];
        }

        {
          _args = [
            "XF86AudioPrev"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl previous\")")
            {
              locked = true;
            }
          ];
        }
      ]

      # -------------------- WORKSPACES 1 - 10 --------------------

      ++ (
        builtins.concatLists (
          builtins.genList (
            i:
            let
              workspace = i + 1;
              key = if workspace == 10 then "0" else toString workspace;
            in
            [
              {
                _args = [
                  (lib.generators.mkLuaInline "mainMod .. \" + ${key}\"")
                  (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = ${toString workspace} })")
                ];
              }

              {
                _args = [
                  (lib.generators.mkLuaInline "mainMod .. \" + SHIFT + ${key}\"")
                  (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = ${toString workspace} })")
                ];
              }
            ]
          ) 10
        )
      );


      # ============================================================
      # WINDOW RULES
      # ============================================================

      window_rule = [

        # -------------------- GENERAL --------------------

        {
          name = "suppress-maximize-events";

          match = {
            class = ".*";
          };

          suppress_event = "maximize";
        }


        # -------------------- XWAYLAND --------------------

        {
          name = "fix-xwayland-drags";

          match = {
            class = "^$";
            title = "^$";
            xwayland = true;
            float = true;
            fullscreen = false;
            pin = false;
          };

          no_focus = true;
        }


        # -------------------- HYPRLAND RUN --------------------

        {
          name = "move-hyprland-run";

          match = {
            class = "hyprland-run";
          };

          move = "20 monitor_h-120";
          float = true;
        }


        # -------------------- BACKGROUND APPS --------------------

        {
          name = "background-apps";

          match = {
            class = "background-apps";
          };

          float = true;
          size = "520 360";
          center = true;
        }

        # -------------------- CALCULATOR --------------------

        {
          name = "quickshell-calculator";

          match = {
            title = "^QS Calculator$";
          };

          float = true;
          size = "840 620";
          center = true;
        }


        # -------------------- NOTES --------------------

        {
          name = "quickshell-notes";

          match = {
            title = "^QS Notes$";
          };

          float = true;
          size = "900 650";
          center = true;
        } 

	    # -------------------- ALARM EDITOR --------------------

	    	{
	    	  name = "quickshell-alarm";

	    	  match = {
	    	    title = "^QS Alarm$";
	    	  };

	    	  float = true;
	    	  size = "440 470";
	    	  center = true;
	    	}


	    	# -------------------- ALARM ALERT --------------------

	    	{
	    	  name = "quickshell-alarm-alert";

	    	  match = {
	    	    title = "^QS Alarm Alert$";
	    	  };

	    	  float = true;
	    	  size = "320 150";

	    	  move = "monitor_w-340 50";
	    	}	
              
      ];


      # ============================================================
      # ANIMATION CURVES
      # ============================================================

      curve = [
        {
          _args = [
            "easeOutQuint"
            {
              type = "bezier";
              points = [
                [ 0.23 1 ]
                [ 0.32 1 ]
              ];
            }
          ];
        }

        {
          _args = [
            "easeInOutCubic"
            {
              type = "bezier";
              points = [
                [ 0.65 0.05 ]
                [ 0.36 1 ]
              ];
            }
          ];
        }

        {
          _args = [
            "linear"
            {
              type = "bezier";
              points = [
                [ 0 0 ]
                [ 1 1 ]
              ];
            }
          ];
        }

        {
          _args = [
            "almostLinear"
            {
              type = "bezier";
              points = [
                [ 0.5 0.5 ]
                [ 0.75 1 ]
              ];
            }
          ];
        }

        {
          _args = [
            "quick"
            {
              type = "bezier";
              points = [
                [ 0.15 0 ]
                [ 0.1 1 ]
              ];
            }
          ];
        }

        {
          _args = [
            "easy"
            {
              type = "spring";
              mass = 1;
              stiffness = 238.1191;
              dampening = 24.21279333;
            }
          ];
        }
      ];


      # ============================================================
      # ANIMATIONS
      # ============================================================

      animation = [
        {
          leaf = "global";
          enabled = true;
          speed = 10;
          bezier = "default";
        }

        {
          leaf = "border";
          enabled = true;
          speed = 5.39;
          bezier = "easeOutQuint";
        }

        {
          leaf = "windows";
          enabled = true;
          speed = 4.79;
          spring = "easy";
        }

        {
          leaf = "windowsIn";
          enabled = true;
          speed = 4.1;
          spring = "easy";
          style = "popin 87%";
        }

        {
          leaf = "windowsOut";
          enabled = true;
          speed = 1.49;
          bezier = "linear";
          style = "popin 87%";
        }

        {
          leaf = "fadeIn";
          enabled = true;
          speed = 1.73;
          bezier = "almostLinear";
        }

        {
          leaf = "fadeOut";
          enabled = true;
          speed = 1.46;
          bezier = "almostLinear";
        }

        {
          leaf = "fade";
          enabled = true;
          speed = 3.03;
          bezier = "quick";
        }

        {
          leaf = "layers";
          enabled = true;
          speed = 3.81;
          bezier = "easeOutQuint";
        }

        {
          leaf = "layersIn";
          enabled = true;
          speed = 4;
          bezier = "easeOutQuint";
          style = "fade";
        }

        {
          leaf = "layersOut";
          enabled = true;
          speed = 1.5;
          bezier = "linear";
          style = "fade";
        }

        {
          leaf = "fadeLayersIn";
          enabled = true;
          speed = 1.79;
          bezier = "almostLinear";
        }

        {
          leaf = "fadeLayersOut";
          enabled = true;
          speed = 1.39;
          bezier = "almostLinear";
        }

        {
          leaf = "workspaces";
          enabled = true;
          speed = 1.94;
          bezier = "almostLinear";
          style = "fade";
        }

        {
          leaf = "workspacesIn";
          enabled = true;
          speed = 1.21;
          bezier = "almostLinear";
          style = "fade";
        }

        {
          leaf = "workspacesOut";
          enabled = true;
          speed = 1.94;
          bezier = "almostLinear";
          style = "fade";
        }

        {
          leaf = "zoomFactor";
          enabled = true;
          speed = 7;
          bezier = "quick";
        }
      ];
    };
  };
}

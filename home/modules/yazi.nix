{ pkgs, ... }:

{
  # -------------------------------------------------------------------
  # GENERAL TOOLS
  # -------------------------------------------------------------------

  home.packages = with pkgs; [
    # USB diagnostics
    usbutils
  ];

  # -------------------------------------------------------------------
  # YAZI
  # -------------------------------------------------------------------

  programs.yazi = {
    enable = true;

    enableBashIntegration = true;
    shellWrapperName = "y";

    # -----------------------------------------------------------------
    # INTERNAL TOOLS
    # -----------------------------------------------------------------

    extraPackages = with pkgs; [
      # File detection / editing
      file
      micro

      # Navigation / search
      fd
      ripgrep
      fzf
      zoxide

      # Archives
      ouch

      # Previews
      jq
      poppler
      ffmpeg
      resvg
      imagemagick

      # Images
      imv

      # GVFS / GIO
      glib

      # GNOME Keyring access (secret-tool)
      libsecret

      # Removable storage utilities
      util-linux
      eject
    ];

    # -----------------------------------------------------------------
    # PLUGINS
    # -----------------------------------------------------------------

    plugins = {
      # Normal USB drives / block devices
      mount = pkgs.yaziPlugins.mount;

      # Android MTP / GVFS / remote filesystems
      gvfs = {
        package = pkgs.yaziPlugins.gvfs;
        setup = true;

        settings = {
          # Use our global GNOME Keyring for credentials.
          password_vault = "keyring";

          # Do not save passwords automatically without asking.
          save_password_autoconfirm = false;
        };
      };

      # Archive preview / compression
      ouch = pkgs.yaziPlugins.ouch;
    };

    # -----------------------------------------------------------------
    # SETTINGS
    # -----------------------------------------------------------------

    settings = {
      mgr = {
        sort_by = "natural";
        sort_dir_first = true;

        show_hidden = false;
        show_symlink = true;

        linemode = "size";
      };

      # ---------------------------------------------------------------
      # OPENERS
      # ---------------------------------------------------------------

      opener = {
        edit = [
          {
            # Open only the first selected file in Micro.
            run = "micro %s1";
            block = true;
            desc = "Edit with Micro";
          }
        ];

        image = [
          {
            # imv can open all selected images.
            run = "imv %s";
            orphan = true;
            desc = "View with imv";
          }
        ];

        extract = [
          {
            run = "ouch d -y %s";
            desc = "Extract here with ouch";
            for = "unix";
          }
        ];
      };

      # ---------------------------------------------------------------
      # OPEN RULES
      # ---------------------------------------------------------------

      open = {
        prepend_rules = [
          # Images
          {
            mime = "image/*";
            use = "image";
          }

          # Archives
          {
            mime = "application/{zip,*rar,*7z*,tar,gzip,x-gzip,x-xz,zstd,bzip*,x-bzip*,x-lzma,x-compress,x-cpio,java-archive}";
            use = "extract";
          }

          # General text files
          {
            mime = "text/*";
            use = "edit";
          }

          # Explicit development/configuration files
          {
            url = "*.nix";
            use = "edit";
          }

          {
            url = "*.py";
            use = "edit";
          }

          {
            url = "*.toml";
            use = "edit";
          }

          {
            url = "*.json";
            use = "edit";
          }

          {
            url = "*.md";
            use = "edit";
          }

          {
            url = "*.txt";
            use = "edit";
          }

          {
            url = "*.yaml";
            use = "edit";
          }

          {
            url = "*.yml";
            use = "edit";
          }

          {
            url = "*.conf";
            use = "edit";
          }

          {
            url = "*.lua";
            use = "edit";
          }

          {
            url = "*.qml";
            use = "edit";
          }
        ];
      };

      # ---------------------------------------------------------------
      # PREVIEWS / GVFS / MTP
      # ---------------------------------------------------------------

      plugin = {
        # GVFS/MTP can be very slow.
        # Do not automatically preload files from phones/devices.
        prepend_preloaders = [
          {
            url = "/run/user/1000/gvfs/**/*";
            run = "noop";
          }
        ];

        prepend_previewers = [
          # IMPORTANT:
          # GVFS comes first so archives/images on a phone do not trigger
          # expensive automatic previews.
          {
            url = "/run/user/1000/gvfs/**/*";
            run = "noop";
          }

          # Archive previews
          {
            mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
            run = "ouch";
          }
        ];
      };
    };

    # -----------------------------------------------------------------
    # THEME / ICONS
    # -----------------------------------------------------------------

    theme = {
      icon = {
        prepend_conds = [
          {
            "if" = "dir";
            text = "";
            fg = "#d7d7dc";
          }

          {
            "if" = "!dir";
            text = "";
            fg = "#b6b6bb";
          }
        ];
      };

      mode = {
        normal_main = {
          fg = "#d7d7dc";
          bg = "#232326";
          bold = true;
        };

        normal_alt = {
          fg = "#7a7a80";
          bg = "#151517";
        };
      };
    };

    # -----------------------------------------------------------------
    # KEYBINDS
    # -----------------------------------------------------------------

    keymap = {
      mgr.prepend_keymap = [
        # -------------------------------------------------------------
        # USB / BLOCK DEVICES
        # -------------------------------------------------------------

        {
          on = [ "M" ];
          run = "plugin mount";
          desc = "Mount manager";
        }

        # -------------------------------------------------------------
        # GVFS / ANDROID / MTP
        # -------------------------------------------------------------

        {
          on = [ "g" "v" ];
          run = "plugin gvfs -- select-then-mount --jump";
          desc = "Mount GVFS device and open";
        }

        {
          on = [ "g" "x" ];
          run = "plugin gvfs -- select-then-unmount";
          desc = "Unmount GVFS device";
        }

        {
          on = [ "g" "j" ];
          run = "plugin gvfs -- jump-to-device";
          desc = "Open mounted GVFS device";
        }

        {
          on = [ "g" "e" ];
          run = "plugin gvfs -- select-then-unmount --eject";
          desc = "Unmount and eject GVFS device";
        }

        # -------------------------------------------------------------
        # ARCHIVES
        # -------------------------------------------------------------

        {
          on = [ "C" ];
          run = "plugin ouch";
          desc = "Compress with ouch";
        }
      ];
    };
  };
}

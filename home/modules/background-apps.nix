{ pkgs, ... }:

{
  home.packages = with pkgs; [
    jq
    procps
    fzf
  ];

  home.file.".local/bin/background-apps" = {
    executable = true;

    text = ''
      #!/usr/bin/env bash

      set -u

      normalize_name() {
        local name="$1"

        name="''${name##*/}"
        name="''${name#.}"
        name="''${name%-wrapped}"

        printf '%s\n' "$name" | tr '[:upper:]' '[:lower:]'
      }

      HYPR_CLASSES="$(
        hyprctl clients -j 2>/dev/null \
          | jq -r '.[].class // empty, .[].initialClass // empty' \
          | tr '[:upper:]' '[:lower:]' \
          | sort -u
      )"

      PROCESS_NAMES="$(
        ps -u "$USER" -o args= \
          | awk '{print $1}' \
          | while IFS= read -r process_path; do
              [ -z "$process_path" ] && continue
              normalize_name "$process_path"
            done \
          | sort -u
      )"

      declare -A shown
      declare -A app_exec

      apps=()

      while IFS= read -r desktop_file; do
        exec_line="$(
          grep -m1 '^Exec=' "$desktop_file" 2>/dev/null \
            | cut -d= -f2-
        )"

        [ -z "$exec_line" ] && continue

        executable="$(
          printf '%s\n' "$exec_line" \
            | awk '{print $1}'
        )"

        [ -z "$executable" ] && continue

        exec_normalized="$(normalize_name "$executable")"

        case "$exec_normalized" in
          xwayland|hyprland|quickshell|kitty|bash|sh|systemd|dbus-daemon|pipewire|wireplumber|*portal*)
            continue
            ;;
        esac

        if ! printf '%s\n' "$PROCESS_NAMES" | grep -Fxq "$exec_normalized"; then
          continue
        fi

        if printf '%s\n' "$HYPR_CLASSES" | grep -Fqi "$exec_normalized"; then
          continue
        fi

        app_name="$(
          grep -m1 '^Name=' "$desktop_file" 2>/dev/null \
            | cut -d= -f2-
        )"

        [ -z "$app_name" ] && app_name="$exec_normalized"

        if [ -n "''${shown[$app_name]+x}" ]; then
          continue
        fi

        shown["$app_name"]=1
        app_exec["$app_name"]="$exec_normalized"
        apps+=("$app_name")

      done < <(
        find -L \
          "$HOME/.local/share/applications" \
          "$HOME/.nix-profile/share/applications" \
          "/etc/profiles/per-user/$USER/share/applications" \
          /run/current-system/sw/share/applications \
          -type f \
          -name '*.desktop' \
          2>/dev/null
      )

      if [ "''${#apps[@]}" -eq 0 ]; then
        printf '\nNo background apps\n\n'
        printf 'Press any key to exit'
        read -r -n1 -s
        exit 0
      fi

      selected="$(
        printf '%s\n' "''${apps[@]}" \
          | sort \
          | fzf \
              --prompt="󰣇  " \
              --pointer="❯" \
              --marker="✓" \
              --height=100% \
              --layout=reverse \
              --border=rounded \
              --info=hidden \
              --no-multi \
              --cycle \
              --header="Background Apps" \
              --header-first \
              --color="fg:#e6edf3,bg:#0d1117,hl:#66d9ff,fg+:#66d9ff,bg+:#161b22,hl+:#66d9ff,pointer:#66d9ff,marker:#66d9ff,border:#30363d,prompt:#66d9ff,header:#8b949e"
      )"

      [ -z "$selected" ] && exit 0

      executable="''${app_exec[$selected]}"

      ps -u "$USER" -o pid=,args= |
      while read -r pid args; do
        process_path="$(
          printf '%s\n' "$args" | awk '{print $1}'
        )"

        [ -z "$process_path" ] && continue

        process_normalized="$(normalize_name "$process_path")"

        if [ "$process_normalized" = "$executable" ]; then
          kill -TERM "$pid" 2>/dev/null
        fi
      done
    '';
  };
}

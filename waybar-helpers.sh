#!/usr/bin/env bash
# Shared helpers for waybar custom modules

# Parse waybar config JSONC to extract module settings
# Usage: waybar_config_get <module> <key> [default]
waybar_config_get() {
  local module=$1 key=$2 default=${3:-}
  local config="$HOME/.config/waybar/config.jsonc"

  local result
  result=$(awk -v mod="\"$module\"" -v k="\"$key\"" '
    { gsub(/\/\/.*/, "") }
    $0 ~ mod { in_mod=1; depth=0 }
    in_mod { depth += gsub(/{/, "{"); depth -= gsub(/}/, "}") }
    in_mod && depth == 0 && NR > 1 { in_mod=0 }
    in_mod && $0 ~ k {
      match($0, /: *"([^"]*)"/, m)
      if (m[1] != "") { print m[1]; exit }
    }
  ' "$config")

  echo "${result:-$default}"
}

# Generate a percentage bar with Pango markup
# Usage: make_bar <pct> <width> <fill_color>
make_bar() {
  local pct=$1 width=$2 fill_color=${3:-#50fa7b}
  local filled=$(awk "BEGIN {printf \"%d\", $pct/100*$width + 0.5}")
  local empty=$((width - filled))
  local bar="<span color='${fill_color}'>"
  for ((i=0; i<filled; i++)); do bar+="━"; done
  bar+="</span>"
  for ((i=0; i<empty; i++)); do bar+="━"; done
  bar+=" ${pct}%"
  echo "$bar"
}

# Collect PIDs running inside docker containers
docker_pids=$(cat /sys/fs/cgroup/system.slice/docker-*/cgroup.procs 2>/dev/null | tr '\n' ' ')
docker_color="#50a0e0"

# Format a process line for tooltip with docker highlighting
# Usage: format_proc_line <value> <name> <suffix>
format_proc_line() {
  local val=$1 name=$2
  if [[ "$name" == *"[D]"* ]]; then
    name="${name% \[D\]}"
    name="${name:0:14}"
    echo "${val}  ${name} <span color='${docker_color}'>[D]</span>"
  else
    name="${name:0:14}"
    echo "${val}  ${name}"
  fi
}

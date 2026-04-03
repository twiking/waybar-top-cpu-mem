# waybar-top-cpu-mem

Custom Waybar modules that show CPU and memory usage with rich tooltips.

## Example

**Bar:**

```
2.1%   8.0G
```

**CPU tooltip:**

```
CPU
━━━━━━━━━━━━━━━━━━━━ 2.1%
  1.2%  claude
  0.3%  brave
  0.3%  kworker
  0.3%  alacritty

Load: 1.08  0.92  0.80
```

**Memory tooltip:**

```
MEMORY
━━━━━━━━━━━━━━━━━━━━ 26.2%
  4.5G  brave
943.1M  slack
558.6M  claude
481.1M  zed-editor
400.4M  claude [D]
205.4M  walker
164.8M  swayosd-server
141.4M  udev-worker
108.7M  marksman

Swap: 2.0G / 34.6G
```

The usage bar is colored green for the filled portion. Titles, values, and icons are colored per module configuration. Docker containers are highlighted with `[D]`.

## How it works

### CPU

CPU usage is normalized across all cores to a 0-100% scale (matching tools like btop). The module runs `top` in batch mode and `ps` together to both measure CPU percentages and resolve process names.

### Memory

Memory is aggregated per process name using RSS from `ps`. Multiple instances of the same process (e.g. browser tabs) are summed together. Values automatically scale between MB and GB.

### Process name resolution

Both modules handle cases where the reported process name is unhelpful:

- `MainThread` (Python apps) - resolved from the command line
- `.foo-wrapped` / `.foo-wrap` (Nix wrappers) - resolved to the actual binary name
- Generic interpreters (`node`, `python`, `bash`, etc.) are skipped in favor of the actual script/app name

### Docker detection

Processes running inside Docker containers are detected via cgroup membership and tagged with `[D]` in the tooltip.

## Installation

Clone the repo wherever you like:

```bash
git clone https://github.com/twiking/waybar-top-cpu-mem.git ~/Dev/waybar-top-cpu-mem
```

Add the modules to your `~/.config/waybar/config.jsonc`:

```jsonc
"modules-right": [
  "custom/top-cpu",
  "custom/top-memory",
  // ...
],

"custom/top-cpu": {
  "exec": "/path/to//waybar-top-cpu-mem/top-cpu.sh",
  "return-type": "json",
  "interval": 3,
  "format": "{}",
  "tooltip": true,
  "icon": "",
  "color": "#ffb86c",
},
"custom/top-memory": {
  "exec": "/path/to//waybar-top-cpu-mem/top-memory.sh",
  "return-type": "json",
  "interval": 3,
  "format": "{}",
  "tooltip": true,
  "icon": "",
  "color": "#8be9fd",
},
```

Restart Waybar to apply.

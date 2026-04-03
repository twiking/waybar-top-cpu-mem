# waybar-top-cpu-mem

Custom Waybar modules that show CPU and memory usage with rich tooltips. Pure bash, no dependencies beyond standard Linux tools.

## Preview

**Bar:** Shows total CPU percentage and memory usage with configurable icons and colors.

**Tooltip (CPU):**
- Usage bar with percentage
- Top 10 processes by CPU, aggregated by name
- Docker containers marked with `[D]`
- Load average (1/5/15 min)

**Tooltip (Memory):**
- Usage bar with percentage
- Top 10 processes by RSS memory, aggregated by name
- Docker containers marked with `[D]`
- Swap usage

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

Add the modules to your `~/.config/waybar/config.jsonc`, pointing `exec` at the repo:

```jsonc
"modules-right": [
  "custom/top-cpu",
  "custom/top-memory",
  // ...
],

"custom/top-cpu": {
  "exec": "~/Dev/waybar-top-cpu-mem/top-cpu.sh",
  "return-type": "json",
  "interval": 3,
  "format": "{}",
  "tooltip": true,
  "icon": "",       // Nerd Font icon (optional)
  "color": "#ffb86c", // Bar text color
},
"custom/top-memory": {
  "exec": "~/Dev/waybar-top-cpu-mem/top-memory.sh",
  "return-type": "json",
  "interval": 3,
  "format": "{}",
  "tooltip": true,
  "icon": "",
  "color": "#8be9fd",
},
```

Restart Waybar to apply.

## Configuration

Each module reads `icon` and `color` from its own section in `config.jsonc`:

| Key | Description | Default |
|-----|-------------|---------|
| `icon` | Nerd Font icon shown after the value | (none) |
| `color` | Pango color for the bar text | `#ffb86c` (cpu) / `#8be9fd` (memory) |

## Requirements

- Waybar
- bash, awk, top, ps, free (standard on any Linux system)
- A Nerd Font (for icons)

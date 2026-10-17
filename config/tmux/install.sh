#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
bin_dir="$HOME/.local/bin"

# Go selects the current OS and architecture; only setup needs the toolchain.
mkdir -p "$bin_dir"
CGO_ENABLED=0 go build -trimpath -o "$bin_dir/tmux-equalize-panes" "$script_dir/equalize-panes.go"
printf 'Installed %s\n' "$bin_dir/tmux-equalize-panes"

# Dotfiles ⚙️

Repo for my local development setup.

This was initially inspired by @timigod's .dotfiles, but I've made some changes that work for me.

If this inspires yours, make the changes that work for you too. ✌🏽

## tmux pane balancing

`install.sh` requires Go 1.21+ to build the pane-balancing helper for the current
OS and CPU architecture. It installs to `~/.local/bin/tmux-equalize-panes` on both
macOS and Linux; Go is not needed when pressing `C-b E`.

After changing the helper, rebuild it with:

```sh
bash ~/.config/tmux/install.sh
```

Run the integration tests from the repo root (requires tmux 3.8+):

```sh
go test -count=1 -v \
  config/tmux/equalize-panes.go config/tmux/equalize-panes_test.go
```

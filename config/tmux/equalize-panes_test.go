package main_test

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"reflect"
	"runtime"
	"strconv"
	"strings"
	"testing"
	"time"
)

type tmuxHarness struct {
	dir, socket, binary, binding string
	env                          []string
}

func command(t *testing.T, env []string, timeout time.Duration, name string, args ...string) string {
	t.Helper()
	ctx, cancel := context.WithTimeout(context.Background(), timeout)
	defer cancel()
	cmd := exec.CommandContext(ctx, name, args...)
	cmd.Env = env
	output, err := cmd.CombinedOutput()
	if err != nil {
		t.Fatalf("%s %v: %v\n%s", name, args, err, output)
	}
	return strings.TrimSpace(string(output))
}

func newHarness(t *testing.T) *tmuxHarness {
	t.Helper()
	tmux, err := exec.LookPath("tmux")
	if err != nil {
		t.Fatal("integration tests require tmux 3.8 or newer:", err)
	}
	goEnv := strings.Split(command(t, os.Environ(), 10*time.Second, "go", "env", "GOROOT", "GOCACHE"), "\n")
	_, source, _, ok := runtime.Caller(0)
	if !ok {
		t.Fatal("cannot locate tmux config")
	}
	config := filepath.Dir(source)
	// Long test names in t.TempDir would exceed Unix socket path limits on macOS.
	dir, err := os.MkdirTemp("", "e-")
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() {
		if err := os.RemoveAll(dir); err != nil {
			t.Error(err)
		}
	})
	home := filepath.Join(dir, "home")
	if err := os.MkdirAll(filepath.Join(home, ".config"), 0755); err != nil {
		t.Fatal(err)
	}
	if err := os.Symlink(config, filepath.Join(home, ".config", "tmux")); err != nil {
		t.Fatal(err)
	}
	h := &tmuxHarness{
		dir: dir, socket: filepath.Join(dir, "s"), binary: tmux,
		env: append(os.Environ(),
			"HOME="+home, "SHELL=/bin/sh", "TERM=xterm-256color", "TMUX=",
			"PATH="+filepath.Join(goEnv[0], "bin")+string(os.PathListSeparator)+os.Getenv("PATH"),
			"GOCACHE="+goEnv[1],
		),
	}
	// Exercise the real installer, but install only into this temporary HOME.
	command(t, h.env, 120*time.Second, "bash", filepath.Join(config, "install.sh"))
	h.tmux(t, "new-session", "-d", "-s", "bootstrap", "-x", "211", "-y", "61", "/bin/sleep 300")
	t.Cleanup(func() { h.tmux(t, "kill-server") })
	h.tmux(t, "set-option", "-g", "status", "off")
	h.tmux(t, "set-option", "-gw", "window-size", "manual")
	h.tmux(t, "source-file", filepath.Join(config, "conf", "tmux-lean_bindings.conf"))
	h.binding = h.tmux(t, "list-keys", "-T", "prefix", "-F", "#{key_command}", "E")
	return h
}

func (h *tmuxHarness) tmux(t *testing.T, args ...string) string {
	t.Helper()
	return command(t, h.env, 5*time.Second, h.binary, append([]string{"-S", h.socket, "-f", "/dev/null"}, args...)...)
}

type fixture struct {
	h     *tmuxHarness
	t     *testing.T
	first string
}

func (h *tmuxHarness) session(t *testing.T) *fixture {
	t.Helper()
	h.tmux(t, "new-session", "-d", "-s", "test", "-x", "211", "-y", "61", "/bin/sleep 300")
	t.Cleanup(func() { h.tmux(t, "kill-session", "-t", "test") })
	return &fixture{h: h, t: t, first: h.tmux(t, "display-message", "-p", "-t", "test", "#{pane_id}")}
}

func (f *fixture) tmux(args ...string) string {
	f.t.Helper()
	return f.h.tmux(f.t, args...)
}

func (f *fixture) split(target, axis string, size int) string {
	f.t.Helper()
	return f.tmux("split-window", "-d", "-"+axis, "-t", target, "-l", strconv.Itoa(size), "-P", "-F", "#{pane_id}", "/bin/sleep 300")
}

type geometry struct{ x, y, width, height int }
type panes map[string]geometry

func (f *fixture) panes() panes {
	f.t.Helper()
	rows := f.tmux("list-panes", "-t", "test", "-F", "#{pane_id} #{pane_left} #{pane_top} #{pane_width} #{pane_height}")
	result := make(panes)
	for _, row := range strings.Split(rows, "\n") {
		var id string
		var g geometry
		if _, err := fmt.Sscanf(row, "%s %d %d %d %d", &id, &g.x, &g.y, &g.width, &g.height); err != nil {
			f.t.Fatal(err)
		}
		result[id] = g
	}
	return result
}

type shape struct {
	Type     string  `json:"t"`
	Index    int     `json:"i"`
	Pane     string  `json:"I"`
	Children []shape `json:"c"`
}

func (f *fixture) shape() shape {
	f.t.Helper()
	var layout struct {
		Root shape `json:"L"`
	}
	raw := f.tmux("display-message", "-p", "-t", "test", "#{window_layout}")
	if err := json.Unmarshal([]byte(raw), &layout); err != nil {
		f.t.Fatal(err)
	}
	return layout.Root
}

func equal(t *testing.T, got, want any) {
	t.Helper()
	if !reflect.DeepEqual(got, want) {
		t.Fatalf("got %#v; want %#v", got, want)
	}
}

func (f *fixture) press() panes {
	f.t.Helper()
	beforeShape := f.shape()
	beforeFocus := f.tmux("display-message", "-p", "-t", "test", "#{pane_id}")
	// Dispatch the configured E command synchronously with the active-pane context.
	f.tmux("if-shell", "-t", beforeFocus, "-F", "1", f.h.binding)
	equal(f.t, f.shape(), beforeShape)
	equal(f.t, f.tmux("display-message", "-p", "-t", "test", "#{pane_id}"), beforeFocus)
	return f.panes()
}

func (f *fixture) nested() (string, string) {
	f.t.Helper()
	right := f.split(f.first, "h", 60)
	return right, f.split(right, "v", 20)
}

func widths(state panes, ids ...string) []int {
	result := make([]int, len(ids))
	for i, id := range ids {
		result[i] = state[id].width
	}
	return result
}

func heights(state panes, ids ...string) []int {
	result := make([]int, len(ids))
	for i, id := range ids {
		result[i] = state[id].height
	}
	return result
}

func verticalGeometry(state panes) map[string][2]int {
	result := make(map[string][2]int)
	for id, g := range state {
		result[id] = [2]int{g.y, g.height}
	}
	return result
}

func TestEqualizePanes(t *testing.T) {
	h := newHarness(t)

	t.Run("NearestAxisThenOuterAxis", func(t *testing.T) {
		f := h.session(t)
		right, bottom := f.nested()
		f.tmux("select-pane", "-t", right)
		first := f.press()
		equal(t, widths(first, f.first, right, bottom), []int{150, 60, 60})
		equal(t, heights(first, right, bottom), []int{30, 30})
		second := f.press()
		equal(t, widths(second, f.first, right, bottom), []int{105, 105, 105})
		equal(t, heights(second, right, bottom), []int{30, 30})
		equal(t, f.press(), second)
	})

	t.Run("OuterAxisPreservesInnerAxis", func(t *testing.T) {
		f := h.session(t)
		right, bottom := f.nested()
		before := f.panes()
		after := f.press()
		equal(t, widths(after, f.first, right, bottom), []int{105, 105, 105})
		equal(t, heights(after, right, bottom), heights(before, right, bottom))
	})

	t.Run("NestedRowsAxisOrder", func(t *testing.T) {
		f := h.session(t)
		bottom := f.split(f.first, "v", 20)
		bottomRight := f.split(bottom, "h", 60)
		f.tmux("select-pane", "-t", bottom)
		first := f.press()
		equal(t, widths(first, bottom, bottomRight), []int{105, 105})
		equal(t, heights(first, f.first, bottom, bottomRight), []int{40, 20, 20})
		second := f.press()
		equal(t, heights(second, f.first, bottom, bottomRight), []int{30, 30, 30})
		equal(t, widths(second, bottom, bottomRight), []int{105, 105})
	})

	t.Run("FourNestedColumns", func(t *testing.T) {
		f := h.session(t)
		columns := []string{f.first}
		for i := 0; i < 3; i++ {
			columns = append(columns, f.split(f.first, "h", 20))
		}
		for _, column := range columns {
			f.split(column, "v", 30)
		}
		f.tmux("select-pane", "-t", f.first)
		after := f.press()
		equal(t, len(after), 8)
		for _, g := range after {
			equal(t, g.width, 52)
			equal(t, g.height, 30)
		}
	})

	t.Run("DeeperParallelSplits", func(t *testing.T) {
		f := h.session(t)
		right, bottom := f.nested()
		topRight := f.split(right, "h", 20)
		bottomRight := f.split(bottom, "h", 35)
		before := f.panes()
		after := f.press()
		equal(t, after[f.first].width, 105)
		equal(t, widths(after, right, topRight, bottom, bottomRight), []int{62, 42, 47, 57})
		equal(t, verticalGeometry(after), verticalGeometry(before))
	})

	t.Run("FlatSiblings", func(t *testing.T) {
		for _, axis := range []string{"h", "v"} {
			for _, count := range []int{2, 3, 5} {
				t.Run(fmt.Sprintf("%s/%d", axis, count), func(t *testing.T) {
					f := h.session(t)
					for i := 1; i < count; i++ {
						f.split(f.first, axis, 5)
					}
					before := f.panes()
					after := f.press()
					smallest, largest, total := 211, 0, 0
					for id, g := range after {
						size := g.width
						if axis == "v" {
							size = g.height
							equal(t, g.width, before[id].width)
						} else {
							equal(t, g.height, before[id].height)
						}
						smallest, largest = min(smallest, size), max(largest, size)
						total += size
					}
					if largest-smallest > 1 {
						t.Fatalf("unequal %s sizes: %#v", axis, after)
					}
					available := 211
					if axis == "v" {
						available = 61
					}
					equal(t, total+count-1, available)
				})
			}
		}
	})

	t.Run("SinglePane", func(t *testing.T) {
		f := h.session(t)
		before := f.panes()
		equal(t, f.press(), before)
	})

	t.Run("NoGoAtRuntime", func(t *testing.T) {
		f := h.session(t)
		runtimeBin := filepath.Join(h.dir, "runtime-bin")
		if err := os.Mkdir(runtimeBin, 0755); err != nil {
			t.Fatal(err)
		}
		if err := os.Symlink(h.binary, filepath.Join(runtimeBin, "tmux")); err != nil {
			t.Fatal(err)
		}
		previousPath := strings.TrimPrefix(f.tmux("show-environment", "-g", "PATH"), "PATH=")
		t.Cleanup(func() { f.tmux("set-environment", "-g", "PATH", previousPath) })
		f.tmux("set-environment", "-g", "PATH", runtimeBin)
		right, bottom := f.nested()
		after := f.press()
		equal(t, widths(after, f.first, right, bottom), []int{105, 105, 105})
	})

	t.Run("MinimumSizes", func(t *testing.T) {
		f := h.session(t)
		f.tmux("resize-window", "-t", "test", "-x", "11")
		right := f.split(f.first, "h", 7)
		f.split(right, "v", 30)
		for i := 0; i < 3; i++ {
			f.split(right, "h", 1)
		}
		before := f.panes()
		equal(t, f.press(), before) // Four panes need seven columns.
		f.tmux("resize-window", "-t", "test", "-x", "15")
		after := f.press()
		equal(t, after[f.first].width, 7)
		for _, g := range after {
			if g.width < 1 {
				t.Fatalf("invalid pane width: %#v", g)
			}
		}
	})
}

// Restore select-layout -E's nested-split behavior on tmux 3.8.
package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"os/exec"
)

// Keep the original JSON fields so pane IDs, focus, and metadata survive.
type cell map[string]any

func (c cell) size(axis string) int {
	return int(c[axis].(float64))
}

func (c cell) children() []cell {
	values, _ := c["c"].([]any)
	children := make([]cell, len(values))
	for i, value := range values {
		children[i] = cell(value.(map[string]any))
	}
	return children
}

func (c cell) dimension() string {
	if c["t"] == "h" {
		return "w"
	}
	return "h"
}

func ancestors(c cell, pane string) ([]cell, bool) {
	if c["t"] == "p" {
		return nil, c["I"] == pane
	}
	for _, child := range c.children() {
		if path, found := ancestors(child, pane); found {
			return append(path, c), true
		}
	}
	return nil, false
}

func minimum(c cell, axis string) int {
	if c["t"] == "p" {
		return 1
	}
	children := c.children()
	if c.dimension() == axis {
		size := len(children) - 1
		for _, child := range children {
			size += minimum(child, axis)
		}
		return size
	}
	size := 0
	for _, child := range children {
		size = max(size, minimum(child, axis))
	}
	return size
}

func resize(c cell, axis string, size int) {
	change := size - c.size(axis)
	c[axis] = float64(size)
	if c["t"] == "p" || change == 0 {
		return
	}
	children := c.children()
	if c.dimension() != axis {
		for _, child := range children {
			resize(child, axis, child.size(axis)+change)
		}
		return
	}

	// Share the delta among parallel children without balancing their existing
	// proportions or shrinking below their minimum, matching tmux's resizing.
	step := 1
	if change < 0 {
		step = -1
	}
	for change != 0 {
		for _, child := range children {
			if change == 0 {
				break
			}
			if step > 0 || child.size(axis) > minimum(child, axis) {
				resize(child, axis, child.size(axis)+step)
				change -= step
			}
		}
	}
}

func position(c cell, x, y int) {
	c["x"], c["y"] = float64(x), float64(y)
	for _, child := range c.children() {
		position(child, x, y)
		if c["t"] == "h" {
			x += child.size("w") + 1
		} else {
			y += child.size("h") + 1
		}
	}
}

func spread(parent cell) bool {
	children := parent.children()
	if len(children) < 2 {
		return false
	}
	axis := parent.dimension()
	available := parent.size(axis) - len(children) + 1
	each, remainder := available/len(children), available%len(children)
	sizes := make([]int, len(children))
	changed := false
	for i, child := range children {
		sizes[i] = each
		if i < remainder {
			sizes[i]++
		}
		if sizes[i] < minimum(child, axis) {
			return false
		}
		changed = changed || sizes[i] != child.size(axis)
	}
	if changed {
		for i, child := range children {
			resize(child, axis, sizes[i])
		}
	}
	return changed
}

func run() error {
	if len(os.Args) != 3 {
		return fmt.Errorf("usage: equalize-panes.go SOCKET PANE")
	}
	socket, pane := os.Args[1], os.Args[2]
	tmux := func(args ...string) ([]byte, error) {
		output, err := exec.Command("tmux", append([]string{"-S", socket}, args...)...).CombinedOutput()
		if err != nil {
			return nil, fmt.Errorf("tmux %s: %w: %s", args[0], err, bytes.TrimSpace(output))
		}
		return output, nil
	}
	raw, err := tmux("display-message", "-p", "-t", pane, "#{window_layout}")
	if err != nil {
		return err
	}
	var layout map[string]any
	if err := json.Unmarshal(raw, &layout); err != nil {
		// Older tmux versions use a non-JSON layout and do not need the fix.
		_, err = tmux("select-layout", "-E", "-t", pane)
		return err
	}
	rootData, ok := layout["L"].(map[string]any)
	if !ok {
		return fmt.Errorf("unsupported tmux layout: missing root")
	}
	root := cell(rootData)
	path, _ := ancestors(root, pane)
	for _, parent := range path {
		if !spread(parent) {
			continue
		}
		position(root, root.size("x"), root.size("y"))
		updated, err := json.Marshal(layout)
		if err != nil {
			return err
		}
		_, err = tmux("select-layout", "-t", pane, string(updated))
		return err // One split, and therefore one axis, per key press.
	}
	return nil
}

func main() {
	if err := run(); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}
}

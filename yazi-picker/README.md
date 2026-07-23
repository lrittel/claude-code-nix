# yazi-picker

A [yazi](https://yazi-rs.github.io/) plugin plus three launcher scripts that
turn yazi into a file/directory picker for use from shell scripts or other
tools, with mode-dependent Enter/Space behavior:

- **`yazi-pick-file`** — single file selection. Space does nothing (no
  multi-selection). Enter on a file picks it and quits. Enter on a directory
  does a "smart enter" (navigates into it).
- **`yazi-pick-files`** — multiple file selection. Space toggles selection
  of the hovered entry. Enter with nothing selected behaves like
  `yazi-pick-file` (pick the hovered file, or smart-enter a directory).
  Enter with an active selection returns the whole selection.
- **`yazi-pick-dir`** — directory selection. Enter on a directory picks it.
  Enter on a file, or in an empty directory (nothing hovered), returns the
  current directory instead.

Each script prints the picked path(s) to stdout, one per line, and exits.
Nothing is printed if the picker is cancelled (e.g. by pressing `q`).

## Usage

```console
$ ./bin/yazi-pick-file
/home/user/notes/todo.md

$ ./bin/yazi-pick-files
/home/user/notes/todo.md
/home/user/notes/ideas.md

$ ./bin/yazi-pick-dir
/home/user/projects/yazi-picker
```

Any extra arguments are passed straight through to `yazi`, e.g. to pick
starting from a specific directory:

```console
$ ./bin/yazi-pick-file ~/projects
```

## How it works

The scripts set `YAZI_CONFIG_HOME` to this directory (so yazi picks up
`keymap.toml` and `plugins/picker.yazi` on top of its normal built-in
defaults — other keybindings are untouched) and `YAZI_PICKER_MODE` to select
the picker's mode, then run `yazi --chooser-file=<tmp>`. The `picker.yazi`
plugin overrides Enter (and, in `files` mode, Space/Ctrl-a/Ctrl-r) to decide
what gets written to the chooser file before quitting.

## Requirements

`yazi` must be installed and on `PATH` (not provided by this repository).

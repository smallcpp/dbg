# Limits relative to cdbg

dbg implements the local GDB session cdbg provides: launch, breakpoints, stepping, and inspection. The items below are the closest behavior the current scpp language and libraries can support.

## Display

The GTK wrapper has no source-view gutter, line marks, or keyboard accelerators. Breakpoints and the stopped line are prefixes on the source text (`*`, `>`), plus a tag on the stopped line. F9, F5, F10, and F11 are not bound. Breakpoint commands use the cursor line. The cursor moves when the view reports a move. There is no click-on-gutter.

Menus cannot hold a check item. Pane visibility is a row of checkboxes. A column view reports row activation, which is how a stack frame or thread is selected.

The header bar is the first row of the window. The wrapper has no call that installs it as the title bar. The session editor is a dialog. That dialog has no close method; dismiss it with the window button. Apply keeps the values either way. Cancel is that button with no Apply.

The wrapper does not report live window resizing. Width, height, and pane positions in `.dbg.toml` are restored. They are not updated from a drag. There is no XDG appearance or keyboard file. cdbg's global XDG state is not read.

There is no separate runtime-values pane. `show_runtime` is stored so a settings file round-trips. Locals and watches are the values view.

## GDB session

GDB is started as `gdb --nx --quiet --interpreter=mi2` with auto-load off, pagination off, mi-async on, confirm off, UTF-8, `may-call-functions` off, print elements 8, and print max-depth 2. One command is in flight. User commands are a high-priority queue and may cancel a low-priority refresh. The window keeps dispatching clicks while GDB works, so Pause can send `-exec-interrupt` during Run. The session test runs that interrupt by starting the program and then interrupting.

There is no pseudo-terminal. Program output is GDB's target stream and raw lines GDB does not wrap as records. The program cannot read standard input. There is no Cwhip Python pretty-printer. Values are GDB's own text. scpp does not use the Cwhip runtime.

scpp's DWARF line table is not source order. A break on `main` stops on the prologue, where arguments can be wrong until the next step. A blank line is rejected. Step over repeats a same-line end-stepping-range stop, up to 8 times. Step into finishes up to 8 frames whose source file cannot be read, unless the stop is a breakpoint.

`-file-list-exec-source-files` is not used. It returns the C library as well as the program, and the result is too large for this session. Source is the target `.scpp` file and the full path of the current stop when that file can be read.

The stack list stops at 31 frames. Locals and threads stop at 64. Watches stop at 64. Breakpoints stop at 256. Console and program output keep 64 KiB. One MI line stops at 1 MiB.

Environment lines are applied with GDB `environment`, and the working directory with `-environment-cd`. There is no unset. Multi-location breakpoints are listed as GDB returns them. There is no extra parent-and-children editor.

Temporary executables live under `/tmp` and are removed when the session closes. Cleanup failure is not given its own dialog. DBG9001 is reserved for that category and is not emitted today.

## Not implemented

Remote debugging, attach, LLDB, DAP, disassembly, and registers are out of scope, as they are for the cdbg prototype this program follows.

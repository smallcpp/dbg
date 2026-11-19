# dbg

`dbg` is a local debugger for scpp. It talks to GDB with the machine interface. A `.scpp` file is compiled with `scpp -g` into a temporary executable. Any other regular file is treated as an executable that already has debug information.

There is no remote debugging, attach, LLDB, or DAP. The differences from cdbg are listed in [limits.md](limits.md).

## Build, test, and install

Use the scripts. Do not run `cmake` yourself.

```sh
scripts/setup
build
build test
install
../bin/dbg
exit
```

`scripts/setup --clean` removes the previous build before configuring. `debug` and `profile` pass `-g` to `scpp`. `build` compiles `bin/dbg` and leaves the test programs unbuilt. `build test` builds those programs and runs the suite. A test that cannot open a display exits 77 and is skipped. The session test needs `gdb` on `PATH`.

`install` builds `dbg` and copies `bin/dbg` into the prefix. A fresh configuration installs to `$HOME/opt/dbg`, so the program is `$HOME/opt/dbg/bin/dbg`. `install /absolute/path` and `install --prefix /absolute/path` install to that prefix for this run. From the checkout root the command is `scripts/install`. A relative prefix is rejected. Test programs are not installed. `scripts/clean` leaves the installed program in place.

`DBG_COMPILER` selects the compiler. The default is `scpp` on `PATH`. `DBG_GDB` selects GDB. The default is `gdb` on `PATH`.

## Command line

```text
dbg --help
dbg [target] [-- arguments...]
```

`--help` prints usage on standard output and exits 0. It ignores arguments after it. An unknown option or an extra positional argument exits 2 with `dbg: error[DBG0001]`. A target that is not a regular file exits 1 with `dbg: error[DBG1001]` before GTK starts. `--` ends option parsing. Arguments after it are the program's arguments, without a shell. No arguments opens the window.

Diagnostics use `dbg: error[DBG####]: ...`. Help goes to standard output. Diagnostics go to standard error.

| Code | When |
|------|------|
| DBG0001 | Command-line usage |
| DBG1000 | The operation does not fit the current state |
| DBG1001 | The target or source cannot be read |
| DBG2001 | Settings cannot be saved |
| DBG3001 | The compiler or its temporary directory failed |
| DBG3002 | GDB failed to start or rejected a command |
| DBG3003 | A pipe, the display, or GDB transport failed |
| DBG3004 | A GDB record exceeded the limit |
| DBG9001 | Reserved for temporary-file cleanup |

## Window

The bar at the top of the window has File, Break, Run, Pause, Into, Over, Out, Restart, and Session.

- **Load** compiles a `.scpp` path or opens an executable, then starts a fresh GDB session and restores that target's saved breakpoints and watches. The program is not run yet.
- **Open source** shows a source file and does not change the session. ELF, NUL bytes, invalid UTF-8, and files over 1 MiB are rejected.
- **Set or clear** uses the cursor line. **Enable or disable** flips the breakpoint on that line. **Condition** and **Ignore** edit that breakpoint. A line with no compiled code is reported and is not installed.
- **Run** starts the program, or continues if it is stopped. **Into**, **Over**, and **Out** step. **Restart** runs from the beginning. A `.scpp` target is compiled again first. **Pause** interrupts a running program.
- **Session** edits break-at-start, arguments, the working directory, and environment lines (`KEY=VALUE`, `#` comments). Apply stores them. Cancel leaves them. A running program keeps the new values until the next Run or Restart.
- **Next** and **Prev** search the open source. The search wraps and says `Wrapped`, or `Not found`.
- The locals, watches, stack, breakpoints, and threads lists show the stopped program. Activating a stack row selects that frame. Activating a thread row selects that thread. Watches are GDB expressions. Calls, assignment, and `++` or `--` are rejected.
- Program output and the debugger console are separate. Breakpoints that were enabled and did not hit during a run are listed as `Not reached`.

Checkboxes show or hide those lists and the two output panes. Break at start stops on `main` before the program runs. The default for a new configuration is on.

Settings are stored in `.dbg.toml` in the current directory. The file is written atomically and is readable only by its owner. A malformed file is kept and is not overwritten.

Closing the window saves settings, stops GDB, removes a temporary executable, and exits. The wrapper has no quit call, so the close handler exits the process.

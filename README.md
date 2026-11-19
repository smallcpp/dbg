# dbg

Local GDB debugger for programs written in scpp. It launches GDB in MI mode, compiles a `.scpp` target with `scpp -g`, and shows the source, breakpoints, stack, locals, watches, threads, program output, and debugger console in a GTK window.

`docs/debugger.md` is the guide. `docs/limits.md` records the cdbg behavior this program does not match, and why. `docs/coding-standard.md` is the smallcpp coding standard.

Use the scripts in `scripts/`. Do not run `cmake` yourself to configure, build, or test. `scripts/setup` configures `build/` and starts a project shell. `build` in that shell compiles `bin/dbg`. `build test` runs the suite. `scripts/clean` removes the build products. No script installs the program: run `bin/dbg`.

`scpp` has to be on `PATH`, or installed at `$HOME/opt/smallcpp`. When `$HOME/.config/smallcpp/config.ini` exists, `scpp` reads header and library locations from it. GDB has to be on `PATH` unless `DBG_GDB` names it.

Start at the checkout root:

```sh
scripts/setup
build
build test
../bin/dbg --help
exit
```

`scripts/setup [--clean] [debug|release|profile]` works from any directory when you invoke this checkout's `scripts/setup`. `--clean` runs `scripts/clean` first. `debug`, `release`, and `profile` set the CMake build type. `debug` and `profile` pass `-g` to `scpp`. The shell reads `.project_env`, puts `bin/` and `scripts/` on `PATH`, and changes to `build/`. When `$HOME/opt/smallcpp/bin` exists, the shell puts that directory on `PATH` as well. `exit` leaves the shell.

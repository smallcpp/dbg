# dbg

Local GDB debugger for programs written in scpp. It launches GDB in MI mode, compiles a `.scpp` target with `scpp -g`, and shows the source, breakpoints, stack, locals, watches, threads, program output, and debugger console in a GTK window.

`docs/debugger.md` is the guide. `docs/limits.md` records the cdbg behavior this program does not match, and why. `docs/coding-standard.md` is the smallcpp coding standard.

Use the scripts in `scripts/`. Do not run `cmake` yourself to configure, build, test, or install. `scripts/setup` configures `build/` and starts a project shell. `build` in that shell compiles `bin/dbg` and leaves the test programs unbuilt. `build test` builds `dbg` and those programs, then runs the suite. `install` builds `dbg` and copies `bin/dbg` into the prefix. `scripts/clean` removes the build products in the checkout. It leaves an installed copy where it is.

`scpp` has to be on `PATH`, or installed at `$HOME/opt/smallcpp`. When `$HOME/.config/smallcpp/config.ini` exists, `scpp` reads header and library locations from it. GDB has to be on `PATH` unless `DBG_GDB` names it.

Start at the checkout root:

```sh
scripts/setup
build
build test
install
../bin/dbg --help
exit
```

`scripts/setup [--clean] [debug|release|profile]` works from any directory when you invoke this checkout's `scripts/setup`. `--clean` runs `scripts/clean` first. `debug`, `release`, and `profile` set the CMake build type. `debug` and `profile` pass `-g` to `scpp`. The shell reads `.project_env`, puts `bin/` and `scripts/` on `PATH`, and changes to `build/`. When `$HOME/opt/smallcpp/bin` exists, the shell puts that directory on `PATH` as well. `exit` leaves the shell.

`install` with no argument uses the prefix selected at configuration. A fresh configuration installs to `$HOME/opt/smallcpp`. The program is `bin/dbg` under that prefix, so the default path is `$HOME/opt/smallcpp/bin/dbg`. `install /absolute/path` and `install --prefix /absolute/path` install to that prefix for this run. A later `install` with no argument uses the configured prefix again. From the checkout root, `scripts/install` and `scripts/install /absolute/path` are the same commands. A relative prefix is rejected. The installed tree is the `dbg` program. Test programs stay in the checkout.

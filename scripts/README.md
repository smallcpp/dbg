# scripts

Helper scripts for this checkout. The root `README.md` and `docs/debugger.md` are the build, test, and install guide. Use these scripts. Do not run `cmake` yourself for configure, build, test, or install.

- `setup [--clean] [debug|release|profile]` configures `build/` and starts a project shell. `build` in that shell compiles `src/dbg.scpp` with `scpp` and leaves the test programs unbuilt. `build test` builds those programs and runs the suite. `--clean` runs `clean` first. `debug`, `release`, and `profile` select the CMake build type. `debug` and `profile` pass `-g` to `scpp`.
- `install [prefix]` builds `dbg` and installs `bin/dbg`. With no argument the prefix is the one selected at configuration. A fresh configuration uses `$HOME/opt/dbg`, so the program is `$HOME/opt/dbg/bin/dbg`. A prefix argument, or `--prefix` and a prefix, installs to that absolute path for this run. A relative prefix is rejected. Test programs are not installed. `clean` does not remove the installed program.
- `clean` removes `bin/`, `build/`, and `lib/`.

Run `bin/dbg` in the checkout, or run `bin/dbg` under the prefix after `install`.

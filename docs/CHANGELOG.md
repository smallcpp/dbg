# Changelog

## Unreleased

- A normal `build` compiles `bin/dbg` and leaves the test programs unbuilt. `build test` builds `bin/dbg` and `test_mi`, `test_args`, `test_settings`, `test_source`, `test_open`, `test_session`, `test_launch`, and `test_ui`, then runs the suite.
- The suite covers MI records, argument and environment text, `.dbg.toml` settings, source loading and search, a GDB session (breakpoints, conditions, watches, stack, stepping, output, interrupt), command-line status codes, and construction of the GTK window.

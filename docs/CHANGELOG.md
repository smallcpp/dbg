# Changelog

## Unreleased

- The session keeps one GDB command in flight. User commands are a high-priority queue and may cancel a low-priority refresh. After a stop the panes fill in order: stack, breakpoints, threads, locals, watches. The GTK loop stays alive during that work. Pause sends `-exec-interrupt` while the inferior runs. Run, step, and Restart are enabled only while stopped; Pause is enabled only while the inferior runs. A spinner beside Pause turns until the driver is idle, including during the refresh.
- Class definitions are in `.shpp` headers. Method bodies written outside the class stay in the matching `.scpp` file, which the build compiles and links. A `.scpp` file is not included.
- A normal `build` compiles `bin/dbg` and leaves the test programs unbuilt. `build test` builds `bin/dbg` and `test_mi`, `test_args`, `test_settings`, `test_source`, `test_open`, `test_session`, `test_launch`, and `test_ui`, then runs the suite.
- The suite covers MI records, argument and environment text, `.dbg.toml` settings, source loading and search, a GDB session (breakpoints, conditions, watches, stack, stepping, output, interrupt), command-line status codes, and construction of the GTK window.

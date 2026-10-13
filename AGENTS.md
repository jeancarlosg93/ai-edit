# AI Edit

Omarchy overlay plugin that rewrites the selected text with a keystroke and
shows the difference before it is pasted back. `docs/design.md` records the
design, the measurements behind it and the open points; read it first.

- Repository text (documentation, comments, commit messages) is English.
- Develop in place: make `~/.config/omarchy/plugins/ai-edit` a symlink to the
  checkout, so changes are tested live. Do not modify `/usr/share/omarchy`.
- The shell does not reload QML from a symlinked checkout: its inotify watcher
  does not follow the symlink, and a rescan keeps the old (or broken)
  component cached. After a QML change run
  `/usr/lib/qt6/bin/qmllint AiEdit.qml Service.qml components/*.qml` (import
  warnings are expected, syntax errors are not), then `omarchy restart shell`.
  A syntax error leaves the AI Edit key doing nothing until the next restart.
- Check QML with `qmllint` only. Do not start `qml`, `qmlscene` or a second
  `quickshell` to try it out: they abort without the shell's environment,
  and each abort is a crash notification on the desktop.
- Run `bin/ai-edit selftest` and `tests/claude-test` before committing; they
  need no compositor and make no Claude requests.
- Text captured from the screen is untrusted and may be large or secret: never
  pass it as a command-line argument, never log it, and keep it in
  `$XDG_RUNTIME_DIR` only.
- Only add a comment when it says something the code cannot: a hidden
  constraint, an invariant, a workaround.

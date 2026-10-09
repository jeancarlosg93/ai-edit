# AI Edit

**Your words, a little better. Right where you're typing.**

Fix a typo in Slack, untangle an email in Gmail or translate a message before
you send it. Select your text, press **Super+E** and choose an action. AI Edit
shows what changed; **Enter** puts the result back.

An [Omarchy](https://omarchy.org) plugin for the moments when you know what you
want to say and just want a hand saying it.

- **Stay in your app.** Edit the text you're already writing, without opening
  a chat and copying the answer back.
- **Keep your voice.** Fix corrects mistakes; Improve clears up muddled
  sentences. Both are instructed to preserve your wording and tone.
- **See every edit.** Removed words are red, additions are green. Review the
  changes before accepting them, or skip the preview when you want to.
- **Feels like part of Omarchy.** Matches your theme and uses familiar
  keyboard controls. Press an action's letter, or use the arrow keys and Enter.
- **Fast.** Short rewrites typically take about one to two seconds.
- **Uses your Claude Code subscription.** No separate API key needed.
  Currently supports Claude Code only.

## Install

You'll need **Omarchy 4.0 or newer** and **Claude Code logged in**.
Run `claude` once if you haven't signed in yet.

Install the plugin:

```bash
omarchy plugin add https://github.com/paulmiddelkoop/ai-edit --enable
```

Add this shortcut to `~/.config/hypr/bindings.lua`:

```lua
o.bind("SUPER + E", "Edit text with AI", os.getenv("HOME") .. "/.config/omarchy/plugins/ai-edit/bin/ai-edit open")
```

**Try it:** select a sentence in a text field, press **Super+E**, then **f**
to fix it. Review the changes and press **Enter**.

## Choose an action

| Key | Action | What it does |
| --- | --- | --- |
| **f** | Fix | Correct spelling, grammar and punctuation. Keep your phrasing. |
| **i** | Improve | Untangle sentences and remove repetition. Keep your voice. |
| **e** | English | Translate into English, keeping the tone of the original. |
| **c** | Custom | Give your own instruction: "make this shorter", "sound a little warmer" or "translate into Swedish". |

For translations and custom instructions, the preview shows the full result
without highlighting individual changes.

You can also build on a result. Improve a message, press **Tab** to see the
actions, then **e** to translate it. **Backspace** takes you back one step.

**Nothing selected?** Super+E opens an empty field. Type something and press
Tab, or paste your text, then choose an action. The result goes to your
clipboard. Text selected on a web page, in a sent message or in a terminal
also gets copied instead of pasted over.

## Keyboard shortcuts

These shortcuts apply when the actions or result have focus. In the text
field, type normally and press Tab to return to the actions.

| Key | What it does |
| --- | --- |
| Action letter | Run that action; on a result, run it on that result (Improve, then English) |
| Shift+letter | Skip the preview and paste or copy the result |
| c | Write a custom instruction |
| Tab | Switch between text and actions |
| Enter | Accept the result: paste over your selection, or copy in clipboard mode |
| y | Copy the result |
| Backspace or ← | Go back one step |
| Esc | Close; in the custom instruction field, dismiss that field first |
| ? | Show or hide actions and key hints |

Shift inverts your preview setting, so it brings the preview back if you've
turned it off. After pasting, your application's Undo brings the original
text back.

In terminal programs that use the mouse, hold Shift while dragging to select
text with the terminal itself.

## Make it yours

The defaults work as they are. To change them, copy the [default config](config.toml):

```bash
mkdir -p ~/.config/ai-edit
cp ~/.config/omarchy/plugins/ai-edit/config.toml ~/.config/ai-edit/config.toml
```

Edit `~/.config/ai-edit/config.toml` to change the model, hide the key hints
with `compact = true`, or add your own actions. For example, append:

```toml
[[action]]
key = "s"
label = "Shorten"
instruction = "Make this text shorter. Keep the main points, wording and tone."
```

Now **s** shortens your selection. Each action needs a unique lowercase key,
a label and an instruction. Keep **c** free if you want custom instructions.

Settings you leave out keep their defaults. If you define actions, your list
replaces the shipped list. Changes apply the next time you open AI Edit.

<details>
<summary>Models and preview settings</summary>

Sonnet is the default. Set `model = "haiku"` or `model = "opus"` at the top of
the config to change it, or inside an action to use that model just for that
action. A new model is kept ready from the next time you open AI Edit.

Set `preview = false` globally or per action to accept results immediately.
Set `diff = false` on an action to preview plain text, useful for translations.
The `width` setting controls the overlay width; the default is `560`.

</details>

## What happens to your text

AI Edit sends the text you choose to Claude through Claude Code, using your
existing account and its usage limits. Each rewrite starts fresh, with no
conversation history, tools or MCP servers, and no saved Claude Code session.

Locally, text stays in your private runtime directory, never in command-line
arguments or AI Edit logs. AI Edit restores the clipboard after capturing
and pasting, and marks pasted results as sensitive so Omarchy's clipboard
history skips them. Choosing **Copy** deliberately puts the result on your
clipboard.

## Under the hood

A small shell script handles selection and paste, a service inside the
Omarchy shell keeps Claude ready (about 240 MB, nearly all of it Claude Code
itself), and a QML overlay shows the result. From a terminal, `ai-edit run`
starts Claude fresh, which takes a second longer.

See the [design notes](docs/plan.md) for the architecture and measurements.
To run the tests without a compositor or Claude requests:

```bash
bin/ai-edit selftest
tests/claude-test
```

## Credits & license

The Wayland selection and paste handling builds on
[OmaPen](https://github.com/vladimirstempel/omapen) by stempelv. Its notes on
Hyprland saved a lot of rediscovery, and AI Edit's system prompt started from
OmaPen's (Copyright (c) 2026 stempelv, MIT License).

AI Edit is [MIT licensed](LICENSE).

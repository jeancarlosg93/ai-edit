# The README demo

`docs/demo.gif` shows AI Edit fixing a short email in Gmail: select, Super+E,
F, the diff, Enter. It is made in two steps:

```bash
docs/demo/record-gmail.sh /tmp/ai-edit-demo   # about 20 s on the live desktop
docs/demo/make-gif.sh /tmp/ai-edit-demo       # writes docs/demo.gif
```

Before recording, open Gmail in Brave (dark mode) with an empty "New
message", the cursor in Subject. The recording switches the theme to Tokyo
Night (Omarchy's default) and back, makes Brave fullscreen and back, pastes
the message into the body, and empties it again afterwards. It aborts before
F or Enter when the overlay is not open, so no key can reach Gmail and send
anything.

Choices made with Paul:

- A real app everybody knows, not a mock-up; Gmail's compose window shows
  nothing private once Brave is fullscreen and the crop stays inside it.
  Slack showed the workspace name and old messages around the composer.
- An ordinary message with everyday typos; jokes in the text fell flat.
- The keys as keyboard keycaps (`caption.py`, SVG through rsvg-convert),
  with a short label; plain text boxes did not read as keys.
- Start with the text unselected and show Ctrl+A, so the whole gesture is
  visible (the first take started with the text already selected).

To make it better next time:

- Use a small compose window (Gmail's pop-out, or Brave not fullscreen but
  a small floating window) so the text and the overlay sit close together
  and the GIF can be cropped tighter. Now the overlay sits right of centre,
  because it opens in the middle of the screen while the text is top left.
- Check the crop, cursor box and caption times in `make-gif.sh` against the
  frames of the new take (`ffmpeg -ss <t> -i raw.mp4 -frames:v 1 f.png`).

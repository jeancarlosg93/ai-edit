#!/bin/bash
# Records the README demo in a Gmail compose window in Brave, then puts the
# theme, fullscreen, focus and clipboard back. Writes raw.mp4 and marks (the
# time of each key from the start of the take) to the directory given.
#
# Before: Gmail open in Brave with an empty "New message", the cursor in
# Subject. Usage: docs/demo/record-gmail.sh <work dir>
set -u
OUT=$(mkdir -p "${1:?work dir}" && cd "$1" && pwd)
S=$(cd "$(dirname "$0")/../.." && pwd)/bin/ai-edit
ST=$XDG_RUNTIME_DIR/ai-edit
MSG="hi mark, sory for teh late reply. lets dicsuss it tomorow, i'll bring coffee"
THEME_BACK=$(omarchy theme current | tr '[:upper:] ' '[:lower:]-')

key() { hyprctl dispatch "hl.dsp.send_key_state({ mods = '$1', key = '$2', state = 'down' })" >/dev/null; sleep 0.05; hyprctl dispatch "hl.dsp.send_key_state({ mods = '$1', key = '$2', state = 'up' })" >/dev/null; sleep 0.1; }
now() { python3 -c "import time; print(time.time())"; }
mark() { echo "$1 $(python3 -c "print(round($(now) - $t0, 2))")" >>"$OUT/marks"; }
overlay() { hyprctl layers -j | jq -e '[.. | objects | select(.namespace? == "ai-edit")] | length > 0' >/dev/null; }
on_brave() { [[ $(hyprctl activewindow -j | jq -r .address) == "$B" ]]; }
abort() { echo "ABORT: $*"; exit 1; }

B=$(hyprctl clients -j | jq -r '.[] | select(.class == "brave-origin" and (.title | test("Gmail"))) | .address' | head -1)
[[ -n $B ]] || { echo "no Gmail window in Brave"; exit 1; }
back=$(hyprctl activewindow -j | jq -r .address)
# The clipboard is saved and put back like bin/ai-edit does it, keeping a
# password manager's mark, or the history would store a copied password.
types=$(wl-paste -l 2>/dev/null); t=$(head -1 <<<"$types")
[[ -n $t ]] && wl-paste -n -t "$t" >"$ST/d0"
sensitive=""; grep -qx 'x-kde-passwordManagerHint' <<<"$types" && sensitive=--sensitive
restore() {
  # The recorder stops first, or it would film the user's own windows coming back.
  if [[ -n ${rec:-} ]]; then kill -INT "$rec" 2>/dev/null; wait "$rec" 2>/dev/null; fi
  omarchy-shell shell hide ai-edit >/dev/null
  hyprctl dispatch "hl.dsp.focus({ window = 'address:$B' })" >/dev/null; sleep 0.4
  # Empty the body again, so no draft with the demo text stays behind.
  if on_brave; then key CTRL A; key '' BackSpace; hyprctl dispatch "hl.dsp.window.fullscreen({ mode = 'fullscreen' })" >/dev/null; fi
  omarchy theme set "$THEME_BACK" >/dev/null 2>&1
  hyprctl dispatch "hl.dsp.focus({ window = 'address:$back' })" >/dev/null
  [[ -s $ST/d0 ]] && wl-copy -t "$t" $sensitive <"$ST/d0"; rm -f "$ST/d0"
}
rec=""
trap restore EXIT
trap 'exit 1' INT TERM
rm -f "$OUT/marks" "$OUT/raw.mp4"

# Tokyo Night is Omarchy's default theme, so the overlay looks as it does out of the box.
omarchy theme set tokyo-night >/dev/null 2>&1; sleep 6
hyprctl dispatch "hl.dsp.focus({ window = 'address:$B' })" >/dev/null; sleep 0.4
on_brave || abort "Brave has no focus"
# Fullscreen hides the tabs, the address bar (with the account) and the inbox
# edges; wait for Brave's "press Esc" toast to go.
hyprctl dispatch "hl.dsp.window.fullscreen({ mode = 'fullscreen' })" >/dev/null; sleep 4
key '' Tab
printf '%s' "$MSG" | wl-copy --sensitive; key CTRL V; sleep 0.4
key CTRL A; sleep 0.3
"$S" capture
[[ $(jq -r .text "$ST/session.json") == "$MSG" && $(jq -r .editable "$ST/session.json") == yes ]] ||
  abort "the body did not hold the message"
# The take starts unselected, so the viewer sees Ctrl+A select the text.
key '' End
hyprctl dispatch "hl.dsp.cursor.move_to_corner({ corner = 0 })" >/dev/null

wf-recorder -o eDP-1 -r 30 -f "$OUT/raw.mp4" >/dev/null 2>&1 & rec=$!
sleep 1.5; t0=$(now)
on_brave || abort "focus moved"
mark "Ctrl+A"; key CTRL A; sleep 1.4
mark "Super+E"; "$S" open; sleep 1.8
# F and Enter go to the overlay only; without it they would reach Gmail.
overlay || abort "overlay did not open"
mark "F"; key '' F
for _ in $(seq 80); do [[ -s $ST/diff.json ]] && break; sleep 0.1; done
overlay && [[ -s $ST/diff.json ]] || abort "no diff"
sleep 2.4
mark "Enter"; key '' Return; sleep 2.8
mark end
kill -INT "$rec"; wait "$rec" 2>/dev/null; rec=""
cat "$OUT/marks"

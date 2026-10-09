#!/bin/bash
# Turns raw.mp4 from record-gmail.sh into docs/demo.gif: cropped to the
# compose window, the cursor painted out after the paste, the keys shown as
# keycaps, the last frame held. Crop, cursor box and key times are for the
# take of October 9, 2026 (3456x2232 screen); check frames and adjust them
# for a new take. Usage: docs/demo/make-gif.sh <work dir> [out.gif]
set -eu
here=$(cd "$(dirname "$0")" && pwd)
cd "${1:?work dir}"
out=${2:-$here/../demo.gif}
CROP=2050:1640:347:93            # w:h:x:y in screen pixels
CURSOR="x=1712:y=1100:w=64:h=80" # where the cursor lands after the paste
CURSOR_FROM=7.15 # GIF time: the take is read from 0.6 s
# file, label, keys; start and end in seconds of the GIF. A take with the
# Ctrl+A step (record-gmail.sh since October 9) adds
# "ctrl-a|select all|Ctrl A|<from>|<to>" before the others.
CAPTIONS=(
  "super-e|open AI Edit|Super E|0.65|2.5"
  "f|Fix|F|2.8|4.7"
  "enter|paste|Enter|6.95|9.0"
)

inputs=() filter="[0:v]delogo=$CURSOR:enable='gte(t,$CURSOR_FROM)',crop=$CROP,scale=1000:-2:flags=lanczos[v0]"
n=0
for caption in "${CAPTIONS[@]}"; do
  IFS='|' read -r name label keys from to <<<"$caption"
  # shellcheck disable=SC2086
  "$here/caption.py" "cap-$name.png" "$label" $keys
  inputs+=(-i "cap-$name.png")
  n=$((n + 1))
  filter+=";[v$((n - 1))][$n:v]overlay=x=(W-w)/2:y=H-h-22:enable='between(t,$from,$to)'[v$n]"
done
filter+=";[v$n]tpad=stop_mode=clone:stop_duration=1.5,fps=15,split[a][b]"
filter+=";[a]palettegen=stats_mode=diff:max_colors=160[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle"
ffmpeg -v error -y -ss 0.6 -i raw.mp4 "${inputs[@]}" -filter_complex "$filter" -loop 0 "$out"
ls -la "$out"

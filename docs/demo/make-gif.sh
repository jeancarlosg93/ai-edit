#!/bin/bash
# Turns a take of record.sh into a GIF: cropped to the compose window, the
# keys shown as keycaps on a strip below it, from the marks the take wrote.
# CUT_TOP and CUT_BOTTOM trim the window in logical pixels (the pop-out's
# address bar, empty space below the overlay); check a frame of a new take
# (`ffmpeg -ss <t> -i raw.mp4 -frames:v 1 f.png`).
# The window's border is trimmed off its sides.
# Usage: docs/demo/make-gif.sh <work dir> <out.gif>
set -eu
here=$(cd "$(dirname "$0")" && pwd)
cd "${1:?work dir}"
out=${2:?out.gif}
CUT_TOP=${CUT_TOP:-0} CUT_BOTTOM=${CUT_BOTTOM:-0}
WIDTH=${WIDTH:-800} STRIP=88 BG=0x1a1b26

read -r crop < <(jq -rn --slurpfile m monitor.json --slurpfile w window.json \
  --argjson top "$CUT_TOP" --argjson bottom "$CUT_BOTTOM" '
  $m[0] as $m | $w[0] as $w | $m.scale as $s |
  [(($w.size[0] - 4) * $s), (($w.size[1] - $top - $bottom) * $s),
   (($w.at[0] - $m.x + 2) * $s), (($w.at[1] - $m.y + $top) * $s)]
  | map(floor) | "\(.[0]):\(.[1]):\(.[2]):\(.[3])"')
mapfile -t marks <marks
start=$(awk -F'|' 'NR == 1 { printf "%.2f", ($1 > 1 ? $1 - 1 : 0) }' marks)

inputs=() filter="[0:v]crop=$crop,scale=$WIDTH:-2:flags=lanczos,pad=iw:ih+$STRIP:0:0:color=$BG[v0]"
n=0
for ((i = 0; i < ${#marks[@]} - 1; i++)); do
  IFS='|' read -r at name label keys <<<"${marks[i]}"
  next=${marks[i + 1]%%|*}
  from=$(awk -v a="$at" -v s="$start" 'BEGIN { printf "%.2f", a - s - 0.1 }')
  to=$(awk -v a="$at" -v b="$next" -v s="$start" 'BEGIN { e = (b - a > 2.6 ? a + 2.6 : b - 0.1); printf "%.2f", e - s }')
  # shellcheck disable=SC2086
  "$here/caption.py" "cap-$name.png" "$label" $keys
  inputs+=(-i "cap-$name.png")
  n=$((n + 1))
  filter+=";[v$((n - 1))][$n:v]overlay=x=(W-w)/2:y=H-h-($STRIP-h)/2:enable='between(t,$from,$to)'[v$n]"
done
filter+=";[v$n]fps=15,split[a][b]"
filter+=";[a]palettegen=stats_mode=full:max_colors=256[p];[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle"
ffmpeg -v error -y -ss "$start" -i raw.mp4 "${inputs[@]}" -filter_complex "$filter" -loop 0 "$out"
ls -la "$out"

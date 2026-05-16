#!/usr/bin/env bash
# Offline audio/video transcription via mlx_whisper on Apple Silicon.
# Usage: transcribe.sh <input> [--lang de|en|...] [--out DIR] [--model NAME] [--translate]
set -euo pipefail

INPUT=""
LANG=""
OUTDIR="$HOME/archive/transcripts"
MODEL="mlx-community/whisper-large-v3-mlx"
TASK="transcribe"

while [ $# -gt 0 ]; do
  case "$1" in
    --lang) LANG="$2"; shift 2 ;;
    --out) OUTDIR="$2"; shift 2 ;;
    --model) MODEL="$2"; shift 2 ;;
    --translate) TASK="translate"; shift ;;
    -h|--help) sed -n '2,4p' "$0"; exit 0 ;;
    *) [ -z "$INPUT" ] && INPUT="$1" || { echo "unexpected: $1" >&2; exit 2; }; shift ;;
  esac
done

[ -n "$INPUT" ] || { echo "missing input path" >&2; exit 2; }
[ -f "$INPUT" ] || { echo "not a file: $INPUT" >&2; exit 2; }

mkdir -p "$OUTDIR"

# Probe + duration
DUR=$(/opt/homebrew/bin/ffprobe -v error -show_entries format=duration -of csv=p=0 "$INPUT" | awk '{printf "%.0f", $1}')
MIN=$((DUR/60)); SEC=$((DUR%60))
ETA=$(awk -v d="$DUR" 'BEGIN{printf "%.0f", d/60/1.4 + 2}')
echo "input: $INPUT"
echo "duration: ${MIN}m${SEC}s  eta(large-v3): ~${ETA}m wall"

# Slug
BASE=$(basename "$INPUT")
SLUG=$(echo "${BASE%.*}" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+|-+$//g')
MP3="$OUTDIR/$SLUG.mp3"

# Extract mono 16k mp3 unless already that
EXT="${INPUT##*.}"
if [ "$EXT" = "mp3" ] && /opt/homebrew/bin/ffprobe -v error -select_streams a:0 \
     -show_entries stream=channels,sample_rate -of csv=p=0 "$INPUT" \
     | grep -q '^1,16000$'; then
  cp -f "$INPUT" "$MP3"
else
  /opt/homebrew/bin/ffmpeg -y -hide_banner -loglevel error \
    -i "$INPUT" -ac 1 -ar 16000 -c:a libmp3lame -q:a 4 "$MP3"
fi
echo "audio: $MP3"

# Transcribe
LANG_FLAG=()
[ -n "$LANG" ] && LANG_FLAG=(--language "$LANG")

"$HOME/.local/bin/mlx_whisper" \
  --model "$MODEL" \
  --task "$TASK" \
  "${LANG_FLAG[@]}" \
  --output-dir "$OUTDIR" \
  --output-format all \
  --verbose False \
  "$MP3"

echo "done. outputs:"
for ext in txt srt vtt json tsv; do
  f="$OUTDIR/$SLUG.$ext"
  [ -f "$f" ] && echo "  $f"
done

# Preview
TXT="$OUTDIR/$SLUG.txt"
if [ -f "$TXT" ]; then
  echo "--- preview ---"
  head -c 200 "$TXT"; echo
fi

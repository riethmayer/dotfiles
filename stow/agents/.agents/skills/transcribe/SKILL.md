---
name: transcribe
description: >
  Offline audio/video transcription on macOS Apple Silicon via mlx_whisper (Metal-accelerated
  Whisper large-v3). Use when the user says "transcribe", "get me a transcript", "convert audio
  to text", "extract subtitles", or mentions any local media file (.mp4 .m4a .mov .wav .mp3
  .flac .ogg .webm) alongside transcription intent. Handles German, English, code-switched
  multilingual content. Produces txt/srt/vtt/json/tsv with timestamps. Runs locally — no API
  calls, no upload.
---

# Transcribe

Local audio/video → text + subtitles. mlx_whisper, Apple Silicon Metal, no network.

## Tools (preinstalled, do not substitute)

- `/opt/homebrew/bin/ffmpeg`, `/opt/homebrew/bin/ffprobe` (Homebrew)
- `/Users/jan/.local/bin/mlx_whisper` (`uv tool install mlx-whisper`)
- Default model: `mlx-community/whisper-large-v3-mlx` (~3 GB, cached after first run)

## When to use what

- **large-v3** (default): multilingual, code-switched, subtitle-quality. ~1.4× realtime on M4 Pro after warmup.
- **medium**: ~2× faster, fine for clean monolingual English.
- **tiny**: drafts only, sub-minute clips.

## Inputs

| arg | required | default |
|---|---|---|
| input path | yes | — |
| `--lang` | no (autodetect if omitted) | — |
| `--out` | no | `~/archive/transcripts/` |
| `--model` | no | `mlx-community/whisper-large-v3-mlx` |
| `--translate` | no | off (set → English translation instead of transcript) |

Code-switching: pass dominant language. Whisper-large-v3 keeps inline foreign words (e.g. English inside German) without translating.

## Workflow

1. **Probe** input with `ffprobe`. Confirm exists. Print duration.
2. **ETA**: `wall_minutes = audio_minutes / 1.4 + 2` (the `+2` covers model load + JIT warmup). Tell the user upfront.
3. **Slug** basename: lowercase, non-alnum → `-`, strip extension.
4. **Extract** mono 16 kHz mp3 → `$OUTDIR/$SLUG.mp3`. Skip if input is already mp3 mono 16 kHz.
5. **Transcribe** in background via `nohup` + `run_in_background: true` (any file >5 min).
6. **Watch** with a backgrounded `until ! pgrep -f "mlx_whisper.*<slug>" >/dev/null; do sleep 30; done; echo DONE` so the agent gets notified on completion and can keep working in parallel.
7. **Report** output paths + 200-char preview of `.txt`.
8. **Keep** the extracted `.mp3` next to outputs (small, useful for re-runs).

## Canonical commands

```bash
# extract
/opt/homebrew/bin/ffmpeg -y -hide_banner -loglevel error \
  -i "INPUT" -ac 1 -ar 16000 -c:a libmp3lame -q:a 4 \
  "OUTPUT_DIR/<slug>.mp3"

# transcribe (all formats: txt srt vtt json tsv)
/Users/jan/.local/bin/mlx_whisper \
  --model mlx-community/whisper-large-v3-mlx \
  --language de \
  --output-dir "OUTPUT_DIR" \
  --output-format all \
  --verbose False \
  "OUTPUT_DIR/<slug>.mp3"
```

## Helper script

`scripts/transcribe.sh <input> [--lang X] [--out DIR] [--model NAME] [--translate]` wraps the workflow. Prefer it over inlining ffmpeg+mlx_whisper unless the caller wants a custom path.

```bash
~/.claude/skills/transcribe/scripts/transcribe.sh \
  "$HOME/archive/Nikolaus _ Jan - LP Introduction - 2025_10_16 08_58 CEST - Recording.mp4" \
  --lang de
```

For long files run it backgrounded:

```bash
nohup ~/.claude/skills/transcribe/scripts/transcribe.sh INPUT --lang de \
  > ~/archive/transcripts/transcription.log 2>&1 &
```

Then watch:

```bash
SLUG="<slug>"
until ! pgrep -f "mlx_whisper.*$SLUG" >/dev/null; do sleep 30; done
echo DONE
```

## Reference: validated run

- Input: `~/archive/Nikolaus _ Jan - LP Introduction - 2025_10_16 08_58 CEST - Recording.mp4` (813 MB, 52 min, DE+EN code-switched)
- Wall: ~37 min on M4 Pro / 24 GB
- Outputs (already on disk, do not overwrite): `~/archive/transcripts/nikolaus-jan-2025-10-16.{txt,srt,vtt,json,tsv,mp3}`

## Why these choices

- **ffmpeg → mono 16 kHz mp3** before Whisper: smaller, deterministic, no video decode in the hot loop. Whisper resamples to 16 kHz internally anyway — feeding it pre-resampled audio skips that work and isolates ffmpeg as the only demuxer.
- **mlx-whisper, not whisper.cpp / openai-whisper**: Metal acceleration without compile, no Python pinning, ~5–10× faster than openai-whisper on Apple Silicon.
- **large-v3 default**: code-switching + multilingual quality is the differentiator; runtime acceptable for personal use. Smaller models miss inline foreign words.
- **Output dir `~/archive/transcripts/`**: source media lives in `~/archive/`.

## Failure modes

- **Disk**: first run downloads ~3 GB to `~/.cache/huggingface/`. Check `df -h ~`.
- **Missing input**: catch via `ffprobe` before invoking mlx_whisper (cheap, fails fast).
- **Sleep kills the job**: long runs need `caffeinate -i ~/.claude/skills/transcribe/scripts/transcribe.sh ...`, or keep the lid open + power connected.
- **Memory**: large-v3 + KV cache ≈ 12 GB. Other heavy apps (browsers, Docker) compete; close them or expect swap thrash.
- **Wrong language hint**: produces fluent-but-wrong output. If autodetect would be safer, omit `--lang`.

## Cleanup

Nothing to clean. The `.mp3` stays. Re-runs are idempotent (mlx_whisper overwrites same-slug outputs).

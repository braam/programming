#!/bin/sh

# Install yt-dlp
## curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o yt-dlp
## chmod a+rx yt-dlp

# Get manifest mpd file using webbrowser, inspect --> network, filter on mpd.

# Check input
if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <mpd-url> <output-name>"
  exit 1
fi

URL="$1"
NAME="$2"

YTDLP="$HOME/Programs/yt-dlp/yt-dlp"
FFMPEG="/usr/bin/ffmpeg"

"$YTDLP" \
  --ffmpeg-location "$FFMPEG" \
  --merge-output-format mkv \
  --add-header "Referer:https://www.vrt.be/" \
  --add-header "Origin:https://www.vrt.be" \
  --retries 10 \
  --fragment-retries 10 \
  --retry-sleep 1:5 \
  --concurrent-fragments 2 \
  --no-part \
  -f "bv*+ba/b" \
  -o "$HOME/Downloads/${NAME}.%(ext)s" \
  "$URL"

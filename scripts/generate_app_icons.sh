#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE_IMAGE="$ROOT_DIR/6f4fc5ed-acf8-4a5f-a448-7b981d761e7a.png"
OUTPUT_DIR="$ROOT_DIR/TapLog/Assets.xcassets/AppIcon.appiconset"

if [[ ! -f "$SOURCE_IMAGE" ]]; then
  echo "Missing source image: $SOURCE_IMAGE" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"

sizes=(
  "20 icon-20.png"
  "29 icon-29.png"
  "40 icon-40.png"
  "58 icon-58.png"
  "60 icon-60.png"
  "76 icon-76.png"
  "80 icon-80.png"
  "87 icon-87.png"
  "120 icon-120.png"
  "152 icon-152.png"
  "167 icon-167.png"
  "180 icon-180.png"
  "1024 icon-1024.png"
)

for item in "${sizes[@]}"; do
  size="${item%% *}"
  filename="${item#* }"
  sips -z "$size" "$size" "$SOURCE_IMAGE" --out "$OUTPUT_DIR/$filename" >/dev/null
done

echo "Generated app icons in $OUTPUT_DIR"

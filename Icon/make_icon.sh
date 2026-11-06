#!/bin/bash
# Icon/make_icon.swift çizimini Resources/AppIcon.icns dosyasına dönüştürür.
set -euo pipefail
cd "$(dirname "$0")/.."

WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

swiftc -O Icon/make_icon.swift -o "$WORK/make_icon"
"$WORK/make_icon" "$WORK/icon.png"

mkdir -p "$WORK/AppIcon.iconset" Resources
for size in 16 32 128 256 512; do
    double=$((size * 2))
    sips -z "$size" "$size" "$WORK/icon.png" --out "$WORK/AppIcon.iconset/icon_${size}x${size}.png" > /dev/null
    sips -z "$double" "$double" "$WORK/icon.png" --out "$WORK/AppIcon.iconset/icon_${size}x${size}@2x.png" > /dev/null
done
iconutil -c icns "$WORK/AppIcon.iconset" -o Resources/AppIcon.icns
echo "Hazır: Resources/AppIcon.icns"

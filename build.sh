#!/bin/bash
# Kullanım: ./build.sh          testleri çalıştırır ve uygulamayı derler
#           ./build.sh install  ayrıca /Applications'a kurup başlatır
set -euo pipefail
cd "$(dirname "$0")"

APP=build/Wheelward.app
SWIFTC=(swiftc -O -swift-version 5 -target arm64-apple-macos13.0)

rm -rf build
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

"${SWIFTC[@]}" Sources/ScrollFlip.swift Tests/main.swift -o build/selftest
build/selftest

"${SWIFTC[@]}" Sources/*.swift -o "$APP/Contents/MacOS/Wheelward"
cp Info.plist "$APP/Contents/Info.plist"
cp Resources/AppIcon.icns "$APP/Contents/Resources/AppIcon.icns"

# Erişilebilirlik izni imzaya bağlıdır; aynı sertifikayla yeniden derlenince izin korunur.
# Sertifika adı SIGN_IDENTITY ortam değişkeninden ya da depoya girmeyen signing.local dosyasından okunur.
# İkisi de yoksa geçici (ad-hoc) imza kullanılır ve her derlemeden sonra izin yeniden verilmelidir.
IDENTITY=${SIGN_IDENTITY:-$(cat signing.local 2>/dev/null || true)}
codesign --force --sign "${IDENTITY:--}" "$APP"
codesign --verify --strict "$APP"
echo "Derlendi: $APP"

if [[ "${1:-}" == "install" ]]; then
    pkill -x Wheelward || true
    while pgrep -x Wheelward > /dev/null; do sleep 0.1; done
    rm -rf /Applications/Wheelward.app
    cp -R "$APP" /Applications/
    open /Applications/Wheelward.app
    echo "Kuruldu: /Applications/Wheelward.app"
fi

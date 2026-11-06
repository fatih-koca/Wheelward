# Wheelward

Windows-style mouse wheel scrolling on macOS, while the trackpad keeps Natural scrolling.

macOS uses a single Natural scrolling setting for both the trackpad and the mouse. Wheelward is a small menu bar app that reverses only classic mouse wheel events. Rolling the wheel toward you scrolls the page down, as it does on Windows.

[Türkçe açıklama aşağıda.](#türkçe)

## How it works

- The app only sees scroll events. It cannot see keyboard input or other mouse events.
- It leaves continuous scroll events alone, which covers the trackpad and the Magic Mouse.
- If Natural scrolling is turned off, it changes nothing, because the wheel already moves the Windows way.
- It applies to every classic wheel mouse rather than to one model.
- Vertical and horizontal (Shift + wheel) scrolling are both reversed.

## Requirements

- An Apple Silicon Mac with macOS 13 or later.
- Xcode or the Xcode Command Line Tools, to build it.

## Build and install

```bash
./build.sh install
```

This runs the tests, builds the app, copies it to `/Applications/Wheelward.app` and starts it. On first launch, turn on Wheelward in System Settings > Privacy & Security > Accessibility.

macOS ties the Accessibility permission to the code signature. To keep the permission across rebuilds, sign with your own certificate. Put its name in a `signing.local` file, which git ignores, or pass it at build time:

```bash
SIGN_IDENTITY="Apple Development: you@example.com (TEAMID)" ./build.sh install
```

Without a certificate the app gets an ad-hoc signature, and you need to grant the permission again after every rebuild.

## Menu

The menu is in Turkish for now:

| Menu item | Meaning |
| --- | --- |
| Tekerleği Çevir | Reverse the wheel (on or off) |
| Erişilebilirlik İzni Ver… | Open the Accessibility settings |
| Girişte Başlat | Start at login |
| Çık | Quit |

## Uninstall

1. In the menu, turn off **Girişte Başlat**, then choose **Çık**.
2. Move `/Applications/Wheelward.app` to the Trash.
3. Remove the entry from System Settings > Privacy & Security > Accessibility.

## License

MIT. See [LICENSE](LICENSE).

---

## Türkçe

Fare tekerleğini Windows yönünde çalıştırır: tekerleği kendine doğru çevirince sayfa aşağı iner. Trackpad, Doğal kaydırma ile çalışmaya devam eder.

### Kullanım

- Menü çubuğundaki fare simgesine tıkla.
- **Tekerleği Çevir:** Aracı açar veya kapatır.
- **Girişte Başlat:** Mac açıldığında aracın kendiliğinden başlamasını sağlar.
- **Çık:** Aracı kapatır. Tekerlek Mac'in varsayılan yönüne döner.

Araç çalışmak için Erişilebilirlik izni ister: Sistem Ayarları > Gizlilik ve Güvenlik > Erişilebilirlik.

### Nasıl çalışır

- Yalnızca kaydırma olaylarını görür. Klavyeyi ve diğer fare olaylarını görmez.
- Sürekli olaylara (trackpad, Magic Mouse) dokunmaz.
- Doğal kaydırma kapalıysa hiçbir şeyi çevirmez, çünkü yön zaten Windows'taki gibidir.
- Bilgisayara bağlı bütün klasik tekerlekli fareleri çevirir, tek bir modele bağlı değildir.

### Kurulum

```bash
./build.sh install
```

Testleri çalıştırır, uygulamayı derler, `/Applications` klasörüne kurar ve başlatır. Erişilebilirlik izni imzaya bağlı olduğundan kendi sertifikanın adını `signing.local` dosyasına yazarsan yeniden derlemelerde izin korunur.

### Kaldırma

1. Menüden **Girişte Başlat** işaretini kaldır, sonra **Çık**'a bas.
2. `/Applications/Wheelward.app` dosyasını Çöp Sepeti'ne at.
3. Sistem Ayarları > Gizlilik ve Güvenlik > Erişilebilirlik listesinden kaydı sil.

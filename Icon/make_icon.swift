// Uygulama simgesini 1024x1024 PNG olarak çizer. Icon/make_icon.sh tarafından çalıştırılır.
import AppKit

func color(_ hex: UInt32) -> NSColor {
    NSColor(
        srgbRed: CGFloat(hex >> 16 & 0xFF) / 255,
        green: CGFloat(hex >> 8 & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: 1)
}

func drawChevron(centerY: CGFloat, pointingUp: Bool) {
    let tip: CGFloat = pointingUp ? 28 : -28
    let path = NSBezierPath()
    path.move(to: NSPoint(x: 512 - 54, y: centerY - tip))
    path.line(to: NSPoint(x: 512, y: centerY + tip))
    path.line(to: NSPoint(x: 512 + 54, y: centerY - tip))
    path.lineWidth = 36
    path.lineCapStyle = .round
    path.lineJoinStyle = .round
    color(0xFF7A1A).setStroke()
    path.stroke()
}

let bitmap = NSBitmapImageRep(
    bitmapDataPlanes: nil, pixelsWide: 1024, pixelsHigh: 1024, bitsPerSample: 8, samplesPerPixel: 4,
    hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)

// macOS simge ızgarasındaki standart yuvarlak kare; gölgeyi sistem ekler.
let background = NSBezierPath(
    roundedRect: NSRect(x: 100, y: 100, width: 824, height: 824), xRadius: 185, yRadius: 185)
NSGradient(starting: color(0x4C8DFF), ending: color(0x2230B5))!.draw(in: background, angle: -90)

let body = NSBezierPath(
    roundedRect: NSRect(x: 312, y: 192, width: 400, height: 640), xRadius: 200, yRadius: 200)
NSGraphicsContext.saveGraphicsState()
let bodyShadow = NSShadow()
bodyShadow.shadowOffset = NSSize(width: 0, height: -16)
bodyShadow.shadowBlurRadius = 44
bodyShadow.shadowColor = NSColor.black.withAlphaComponent(0.35)
bodyShadow.set()
color(0xFFFFFF).setFill()
body.fill()
NSGraphicsContext.restoreGraphicsState()
NSGradient(starting: color(0xFFFFFF), ending: color(0xD9E3F5))!.draw(in: body, angle: -90)

// Tuşları gövdeden ayıran çizgi.
NSGraphicsContext.saveGraphicsState()
body.addClip()
let split = NSBezierPath()
split.move(to: NSPoint(x: 312, y: 400))
split.line(to: NSPoint(x: 712, y: 400))
split.lineWidth = 10
color(0xB9C6DE).setStroke()
split.stroke()
NSGraphicsContext.restoreGraphicsState()

color(0x1C2A6B).setFill()
NSBezierPath(roundedRect: NSRect(x: 480, y: 547, width: 64, height: 136), xRadius: 32, yRadius: 32).fill()
drawChevron(centerY: 745, pointingUp: true)
drawChevron(centerY: 485, pointingUp: false)

NSGraphicsContext.current = nil
try bitmap.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))

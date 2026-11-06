import CoreGraphics
import Foundation

/// Kaydırma olaylarını uygulamalara ulaşmadan önce yakalayan olay kancası.
final class WheelTap {
    private var port: CFMachPort?
    private var source: CFRunLoopSource?

    var isInstalled: Bool { port != nil }

    func install() {
        guard port == nil else { return }
        guard let newPort = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.scrollWheel.rawValue),
            callback: wheelTapCallback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            NSLog("Kanca kurulamadı")
            return
        }
        let newSource = CFMachPortCreateRunLoopSource(nil, newPort, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), newSource, .commonModes)
        CGEvent.tapEnable(tap: newPort, enable: true)
        port = newPort
        source = newSource
        NSLog("Kanca kuruldu")
    }

    func remove() {
        guard let port else { return }
        CGEvent.tapEnable(tap: port, enable: false)
        if let source {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }
        CFMachPortInvalidate(port)
        self.port = nil
        source = nil
        NSLog("Kanca kaldırıldı")
    }

    /// macOS kancayı kapattıysa yeniden açar; geçersiz kaldıysa kaldırır ki yeniden kurulabilsin.
    func repair() {
        guard let port else { return }
        if !CFMachPortIsValid(port) {
            remove()
        } else if !CGEvent.tapIsEnabled(tap: port) {
            CGEvent.tapEnable(tap: port, enable: true)
            NSLog("Kanca yeniden açıldı")
        }
    }
}

private func wheelTapCallback(
    proxy: CGEventTapProxy,
    type: CGEventType,
    event: CGEvent,
    context: UnsafeMutableRawPointer?
) -> Unmanaged<CGEvent>? {
    switch type {
    case .scrollWheel:
        ScrollFlip.reverseIfNeeded(event)
    case .tapDisabledByTimeout, .tapDisabledByUserInput:
        if let context {
            Unmanaged<WheelTap>.fromOpaque(context).takeUnretainedValue().repair()
        }
    default:
        break
    }
    return Unmanaged.passUnretained(event)
}

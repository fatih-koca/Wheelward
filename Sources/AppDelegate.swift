import AppKit
import ApplicationServices
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private static let enabledKey = "enabled"
    private static let pollInterval: TimeInterval = 2
    private static let accessibilitySettingsURL = URL(
        string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!

    private let wheelTap = WheelTap()
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let statusLine = NSMenuItem()
    private let enabledItem = NSMenuItem(
        title: "Tekerleği Çevir", action: #selector(toggleEnabled), keyEquivalent: "")
    private let permissionItem = NSMenuItem(
        title: "Erişilebilirlik İzni Ver…", action: #selector(openAccessibilitySettings), keyEquivalent: "")
    private let loginItem = NSMenuItem(
        title: "Girişte Başlat", action: #selector(toggleLoginItem), keyEquivalent: "")
    private var currentSymbol = ""

    private var isEnabled: Bool {
        get { UserDefaults.standard.object(forKey: Self.enabledKey) as? Bool ?? true }
        set { UserDefaults.standard.set(newValue, forKey: Self.enabledKey) }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        buildMenu()
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
        reconcile()
        let timer = Timer(
            timeInterval: Self.pollInterval, target: self, selector: #selector(reconcile),
            userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
    }

    func menuWillOpen(_ menu: NSMenu) {
        refreshLoginItem()
    }

    private func buildMenu() {
        for item in [enabledItem, permissionItem, loginItem] {
            item.target = self
        }
        let menu = NSMenu()
        menu.delegate = self
        menu.addItem(statusLine)
        menu.addItem(.separator())
        menu.addItem(enabledItem)
        menu.addItem(permissionItem)
        menu.addItem(loginItem)
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Çık", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        refreshLoginItem()
    }

    /// İstenen durumla gerçek durumu eşitler. İzin geri alındığında çalışan bir kanca
    /// sistem girdisini kilitleyebileceği için hemen kaldırılır.
    @objc private func reconcile() {
        let trusted = AXIsProcessTrusted()
        if isEnabled && trusted {
            wheelTap.repair()
            wheelTap.install()
        } else {
            wheelTap.remove()
        }
        updateStatus(trusted: trusted)
    }

    private func updateStatus(trusted: Bool) {
        let symbol: String
        if !trusted {
            statusLine.title = "Erişilebilirlik izni gerekiyor"
            symbol = "exclamationmark.triangle"
        } else if !isEnabled {
            statusLine.title = "Kapalı: tekerlek Mac yönünde"
            symbol = "computermouse"
        } else if wheelTap.isInstalled {
            statusLine.title = "Açık: tekerlek Windows yönünde"
            symbol = "computermouse.fill"
        } else {
            statusLine.title = "Başlatılamadı, yeniden deneniyor"
            symbol = "exclamationmark.triangle"
        }
        permissionItem.isHidden = trusted
        enabledItem.state = isEnabled ? .on : .off
        if symbol != currentSymbol {
            currentSymbol = symbol
            statusItem.button?.image = NSImage(systemSymbolName: symbol, accessibilityDescription: "Wheelward")
        }
    }

    private func refreshLoginItem() {
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
    }

    @objc private func toggleEnabled() {
        isEnabled.toggle()
        reconcile()
    }

    @objc private func openAccessibilitySettings() {
        NSWorkspace.shared.open(Self.accessibilitySettingsURL)
    }

    @objc private func toggleLoginItem() {
        let service = SMAppService.mainApp
        do {
            if service.status == .enabled {
                try service.unregister()
            } else {
                try service.register()
            }
        } catch {
            NSApp.activate(ignoringOtherApps: true)
            NSAlert(error: error).runModal()
        }
        if service.status == .requiresApproval {
            SMAppService.openSystemSettingsLoginItems()
        }
        refreshLoginItem()
    }
}

import AppKit
import SwiftUI

// MARK: - AppDelegate

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    var dockWindowController: MainWindowController?
    private var statusBarItem: NSStatusItem?

    let dockViewModel: DockViewModel
    let settingsViewModel: SettingsViewModel

    override init() {
        self.dockViewModel = DockViewModel()
        self.settingsViewModel = SettingsViewModel()
        super.init()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Run as accessory — no Dock icon for the app itself
        NSApp.setActivationPolicy(.accessory)

        setupDockWindow()
        setupStatusBar()
        setupScreenChangeObserver()
    }

    func applicationWillTerminate(_ notification: Notification) {
        dockViewModel.saveConfiguration()
    }

    // MARK: - Setup

    private func setupDockWindow() {
        dockWindowController = MainWindowController(
            dockViewModel: dockViewModel,
            settingsViewModel: settingsViewModel
        )
        dockWindowController?.showWindow(nil)
        dockWindowController?.positionWindow(
            for: settingsViewModel.dockEdge,
            offset: settingsViewModel.edgeOffset
        )
    }

    private func setupStatusBar() {
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem?.button?.image = NSImage(
            systemSymbolName: "dock.rectangle",
            accessibilityDescription: "Extradock"
        )
        statusBarItem?.menu = buildStatusMenu()
    }

    private func buildStatusMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(
            NSMenuItem(title: "Show/Hide Dock", action: #selector(toggleDock), keyEquivalent: "d")
        )
        menu.addItem(.separator())
        menu.addItem(
            NSMenuItem(title: "Settings…", action: #selector(openSettings), keyEquivalent: ",")
        )
        menu.addItem(.separator())
        menu.addItem(
            NSMenuItem(title: "Quit Extradock", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        )
        return menu
    }

    private func setupScreenChangeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleScreenChange),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    // MARK: - Actions

    @objc private func toggleDock() {
        dockViewModel.toggleVisibility()
        if dockViewModel.isVisible {
            dockWindowController?.slideIn()
            dockWindowController?.showWindow(nil)
        } else {
            dockWindowController?.slideOut()
        }
    }

    @objc private func openSettings() {
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func handleScreenChange() {
        dockWindowController?.positionWindow(
            for: settingsViewModel.dockEdge,
            offset: settingsViewModel.edgeOffset
        )
    }
}

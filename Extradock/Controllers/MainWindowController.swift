import AppKit
import SwiftUI

// MARK: - MainWindowController

final class MainWindowController: NSWindowController {
    private let dockViewModel: DockViewModel
    private let settingsViewModel: SettingsViewModel

    init(dockViewModel: DockViewModel, settingsViewModel: SettingsViewModel) {
        self.dockViewModel = dockViewModel
        self.settingsViewModel = settingsViewModel

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 80),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        panel.level = .floating
        panel.collectionBehavior = [
            .canJoinAllSpaces,
            .fullScreenAuxiliary,
            .stationary
        ]
        panel.isMovableByWindowBackground = false
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.isReleasedWhenClosed = false

        let contentView = DockContainerView()
            .environmentObject(dockViewModel)
            .environmentObject(settingsViewModel)

        panel.contentView = NSHostingView(rootView: contentView)

        super.init(window: panel)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Positioning

    func positionWindow(for edge: DockEdge, offset: Double) {
        guard let window, let screen = NSScreen.main else { return }
        let screenFrame = screen.visibleFrame
        let windowSize = window.frame.size
        let origin = windowOrigin(
            edge: edge,
            offset: offset,
            screenFrame: screenFrame,
            windowSize: windowSize
        )
        window.setFrameOrigin(origin)
    }

    func windowOrigin(
        edge: DockEdge,
        offset: Double,
        screenFrame: CGRect,
        windowSize: CGSize
    ) -> CGPoint {
        switch edge {
        case .bottom:
            return CGPoint(
                x: screenFrame.midX - windowSize.width / 2 + offset,
                y: screenFrame.minY
            )
        case .left:
            return CGPoint(
                x: screenFrame.minX,
                y: screenFrame.midY - windowSize.height / 2 + offset
            )
        case .right:
            return CGPoint(
                x: screenFrame.maxX - windowSize.width,
                y: screenFrame.midY - windowSize.height / 2 + offset
            )
        }
    }

    // MARK: - Animations

    func slideIn() {
        guard let window else { return }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().alphaValue = 1.0
        }
    }

    func slideOut() {
        guard let window else { return }
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().alphaValue = 0.0
        }
    }
}

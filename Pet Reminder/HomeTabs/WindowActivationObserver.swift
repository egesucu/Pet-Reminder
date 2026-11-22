import SwiftUI
import UIKit

// Multiple iPad scenes can be active simultaneously. Route App Intents to the
// key window, rather than allowing every scene to consume the same request.
struct WindowActivationObserver: UIViewRepresentable {
    let activate: () -> Void
    let deactivate: () -> Void
    func makeUIView(context: Context) -> ActivationView {
        let view = ActivationView()
        view.activate = activate
        view.deactivate = deactivate
        return view
    }
    func updateUIView(_ view: ActivationView, context: Context) {
        view.activate = activate
        view.deactivate = deactivate
    }

    final class ActivationView: UIView {
        var activate: (() -> Void)?
        var deactivate: (() -> Void)?
        private var resignObserver: (any NSObjectProtocol)?
        private var observer: (any NSObjectProtocol)?
        override func didMoveToWindow() {
            super.didMoveToWindow()
            if let observer { NotificationCenter.default.removeObserver(observer) }
            if let resignObserver { NotificationCenter.default.removeObserver(resignObserver) }
            observer = nil
            resignObserver = nil
            guard let window else { deactivate?(); return }
            let currentWindow = window
            resignObserver = NotificationCenter.default.addObserver(
                forName: UIWindow.didResignKeyNotification, object: currentWindow, queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated { self?.deactivate?() }
            }
            if window.isKeyWindow { activate?() }
            observer = NotificationCenter.default.addObserver(
                forName: UIWindow.didBecomeKeyNotification, object: window, queue: .main
            ) { [weak self] _ in
                MainActor.assumeIsolated { self?.activate?() }
            }
        }
        isolated deinit {
            if let observer { NotificationCenter.default.removeObserver(observer) }
            if let resignObserver { NotificationCenter.default.removeObserver(resignObserver) }
        }
    }
}

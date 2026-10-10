import EventKitUI
import SwiftUI

struct EventEditor: UIViewControllerRepresentable {
    let event: EKEvent
    let eventStore: EKEventStore
    var onComplete: () -> Void

    func makeUIViewController(context: Context) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        // Editing must use the same store that owns the selected event.
        controller.eventStore = eventStore
        controller.event = event
        controller.editViewDelegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: EKEventEditViewController, context: Context) {
        // Do not replace the editor's event while a draft is open.
        context.coordinator.onComplete = onComplete
    }

    func makeCoordinator() -> Coordinator { Coordinator(onComplete: onComplete) }

    final class Coordinator: NSObject, EKEventEditViewDelegate {
        var onComplete: () -> Void
        init(onComplete: @escaping () -> Void) { self.onComplete = onComplete }

        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            onComplete()
        }
    }
}

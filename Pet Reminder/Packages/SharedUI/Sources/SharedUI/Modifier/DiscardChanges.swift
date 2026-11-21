import SwiftUI
import Shared

public extension View {
    func confirmDiscardChanges(isPresented: Binding<Bool>, discard: @escaping () -> Void) -> some View {
        confirmationDialog(Text(SharedStrings.resource("Discard changes?")), isPresented: isPresented, titleVisibility: .visible) {
            Button(SharedStrings.resource("Discard changes"), role: .destructive, action: discard)
            Button(SharedStrings.cancelTitle, role: .cancel) { }
        }
    }
}

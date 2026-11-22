import SwiftUI

private struct AdaptivePickerStyle: ViewModifier {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    func body(content: Content) -> some View {
        if dynamicTypeSize.isAccessibilitySize {
            content.pickerStyle(.menu)
        } else {
            content.pickerStyle(.segmented)
        }
    }
}

public extension View {
    func adaptivePickerStyle() -> some View {
        modifier(AdaptivePickerStyle())
    }
}

import Shared
import SwiftUI

/// Displays one meal’s state and forwards activation to the feature that owns feeding.
public struct MealButton: View {
    public enum Meal {
        case morning
        case evening

        fileprivate var title: LocalizedStringResource {
            switch self {
            case .morning: SharedStrings.feedSelectionMorning
            case .evening: SharedStrings.feedSelectionEvening
            }
        }

        fileprivate var symbol: String {
            switch self {
            case .morning: "sun.max"
            case .evening: "moon"
            }
        }
    }

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let meal: Meal
    private let isFed: Bool
    private let action: () -> Void

    public init(meal: Meal, isFed: Bool, action: @escaping () -> Void) {
        self.meal = meal
        self.isFed = isFed
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Label {
                Text(meal.title)
                    .multilineTextAlignment(.leading)
            } icon: {
                Image(systemName: isFed ? "checkmark" : meal.symbol)
            }
            .font(.title2.bold(isFed))
            .foregroundStyle(.primary)
            .padding(.horizontal, .spacing16)
            .frame(minWidth: 44, minHeight: 44)
            .background(Color(uiColor: .tertiarySystemGroupedBackground), in: Capsule())
            .overlay {
                Capsule().strokeBorder(.primary, lineWidth: isFed ? 2 : 1)
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityValue(Text(isFed ? SharedStrings.resource("Fed") : SharedStrings.resource("Not fed")))
        .animation(reduceMotion ? nil : .smooth, value: isFed)
        .sensoryFeedback(.selection, trigger: isFed)
    }
}

#if DEBUG
#Preview {
    @Previewable @State var isFed = false

    MealButton(meal: .morning, isFed: isFed) { isFed.toggle() }
        .padding()
}
#endif

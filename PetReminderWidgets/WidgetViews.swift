import AppIntents
import SwiftUI
import UIKit
import WidgetKit

private enum CareStyle {
    static let mint = Color(red: 0.13, green: 0.65, blue: 0.49)
}

struct CareBackground: View {
    @Environment(\.colorScheme) private var scheme
    var body: some View {
        LinearGradient(colors: scheme == .dark
                       ? [Color(red: 0.08, green: 0.18, blue: 0.17), Color(red: 0.04, green: 0.10, blue: 0.12)]
                       : [Color(red: 0.91, green: 0.98, blue: 0.94), Color(red: 0.98, green: 0.98, blue: 0.94)],
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct PetPortrait: View {
    let pet: WidgetPet
    var size: CGFloat = 48
    var body: some View {
        Group {
            if let data = pet.photo, let image = UIImage(data: data) {
                Image(uiImage: image).resizable()
                    .widgetAccentedRenderingMode(.accentedDesaturated)
                    .scaledToFill()
            } else {
                ZStack {
                    Circle().fill(CareStyle.mint.opacity(0.16))
                    Image(systemName: pet.symbolName)
                        .font(.system(size: size * 0.42, weight: .semibold))
                        .foregroundStyle(CareStyle.mint)
                        .widgetAccentable()
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityHidden(true)
    }
}

struct CareRing: View {
    let completed: Int
    let total: Int
    var size: CGFloat = 60
    var body: some View {
        ZStack {
            Circle().stroke(CareStyle.mint.opacity(0.16), lineWidth: 6)
            Circle().trim(from: 0, to: total > 0 ? Double(completed) / Double(total) : 0)
                .stroke(CareStyle.mint, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .widgetAccentable()
            Text("\(completed)/\(total)")
                .monospacedDigit()
                .contentTransition(.numericText())
                .font(.system(.headline, design: .rounded, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
                .padding(size <= 36 ? 5 : 8)
        }
        .frame(width: size, height: size)
        .animation(.easeInOut(duration: 0.25), value: completed)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(completed) of \(total) meals given"))
    }
}

private struct MealToggle: View {
    let pet: WidgetPet
    let meal: WidgetMeal
    let day: Date
    var compact = false

    private var fed: Bool { meal == .morning ? pet.morningFed : pet.eveningFed }

    var body: some View {
        Toggle(isOn: fed, intent: ToggleWidgetMealIntent(petID: pet.id, meal: meal, day: day, expectedFed: fed)) {
            Text(meal == .morning ? LocalizedStringKey("Morning") : LocalizedStringKey("Evening"))
        }
        .toggleStyle(MealToggleStyle(morning: meal == .morning, compact: compact))
    }
}

private struct MealToggleStyle: ToggleStyle {
    let morning: Bool
    let compact: Bool

    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            // WidgetKit renders both states so the checkmark can change before the save completes.
            MealControlLabel(morning: morning, fed: configuration.isOn, compact: compact)
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(morning ? Text("Morning") : Text("Evening"))
        .accessibilityValue(configuration.isOn ? Text("Fed") : Text("Not fed"))
        .accessibilityHint(Text("Update Meal Status"))
    }
}

struct EmptyCareView: View {
    let hasSnapshot: Bool
    var missingPet = false
    private var message: LocalizedStringKey {
        if missingPet { return "Edit this widget to pick another pet." }
        return hasSnapshot ? "Add your first pet to get started." : "Open Pet Reminder to see your pets here."
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: "heart.fill")
                .font(.title2).foregroundStyle(CareStyle.mint).widgetAccentable()
            Text(missingPet ? LocalizedStringKey("Choose a pet") : LocalizedStringKey("A little care, every day."))
                .font(.system(.headline, design: .rounded))
            Text(message)
                .font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}

struct SmallPetCareCard: View {
    let pet: WidgetPet
    let day: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                PetPortrait(pet: pet, size: 32)
                Text(pet.name)
                    .font(.system(.subheadline, design: .rounded, weight: .bold))
                    .lineLimit(2).minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            VStack(alignment: .leading, spacing: 5) {
                Text("\(pet.completed)/\(pet.scheduled) today")
                    .monospacedDigit()
                    .contentTransition(.numericText())
                    .font(.caption).foregroundStyle(.secondary)
                    .lineLimit(1).minimumScaleFactor(0.85)
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule().fill(CareStyle.mint.opacity(0.16))
                        Capsule().fill(CareStyle.mint)
                            .frame(width: geometry.size.width * Double(pet.completed) / Double(max(1, pet.scheduled)))
                            .widgetAccentable()
                    }
                }
                .frame(height: 4)
                .animation(.easeInOut(duration: 0.25), value: pet.completed)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text("\(pet.completed) of \(pet.scheduled) meals given"))
            }
            Spacer(minLength: 0)
            HStack(spacing: 6) {
                if pet.morningScheduled {
                    MealToggle(pet: pet, meal: .morning, day: day, compact: true)
                }
                if pet.eveningScheduled {
                    MealToggle(pet: pet, meal: .evening, day: day, compact: true)
                }
            }
        }
    }
}

private struct MealControlLabel: View {
    let morning: Bool
    let fed: Bool
    let compact: Bool

    var body: some View {
        let layout = compact ? AnyLayout(VStackLayout(spacing: 3)) : AnyLayout(HStackLayout(spacing: 6))
        let shape = RoundedRectangle(cornerRadius: 12)

        layout {
            Image(systemName: fed ? "checkmark.circle.fill" : "circle")
                .font(.system(.subheadline, weight: .semibold))
                .foregroundStyle(fed ? CareStyle.mint : .primary)
                .widgetAccentable(fed)
            Text(morning ? LocalizedStringKey("Morning") : LocalizedStringKey("Evening"))
                .font(.system(compact ? .caption2 : .caption, design: .rounded, weight: .semibold))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .padding(.horizontal, 4)
        .frame(maxWidth: .infinity, minHeight: 44)
        .background(.primary.opacity(0.06), in: shape)
        .overlay {
            shape.strokeBorder(.primary.opacity(0.16))
        }
    }
}

struct SmallCareOverviewCard: View {
    let entry: CareEntry
    private var completed: Int { entry.pets.reduce(0) { $0 + $1.completed } }
    private var total: Int { entry.pets.reduce(0) { $0 + $1.scheduled } }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Your pets")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .lineLimit(1).minimumScaleFactor(0.85)
            Label {
                Text(entry.date, format: .dateTime.month(.abbreviated).day())
            } icon: {
                Image(systemName: "heart").foregroundStyle(CareStyle.mint).widgetAccentable()
            }
            .font(.caption2).foregroundStyle(.secondary)
            .lineLimit(1)
            .padding(.top, 2)
            Spacer(minLength: 6)
            HStack(spacing: 10) {
                CareRing(completed: completed, total: total, size: 46)
                Text(completed == total ? LocalizedStringKey("Everyone's all fed.") : LocalizedStringKey("\(total - completed) meals to go"))
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .lineLimit(3).minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Spacer(minLength: 6)
            HStack(spacing: 6) {
                HStack(spacing: -6) {
                    ForEach(Array(entry.pets.prefix(3))) { pet in
                        PetPortrait(pet: pet, size: 26)
                            .overlay(Circle().stroke(.primary.opacity(0.1), lineWidth: 1))
                    }
                }
                if entry.pets.count > 3 {
                    Text("+\(entry.pets.count - 3)")
                        .font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct PetFeedingView: View {
    let entry: CareEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            if let pet = entry.selectedPet {
                if family == .accessoryCircular {
                    Gauge(value: Double(pet.completed), in: 0...Double(max(1, pet.scheduled))) {
                        Image(systemName: pet.symbolName)
                    } currentValueLabel: { Text("\(pet.completed)/\(pet.scheduled)") }
                        .gaugeStyle(.accessoryCircular)
                        .accessibilityLabel(Text("\(pet.name): \(pet.completed) of \(pet.scheduled) meals given"))
                } else if family == .accessoryRectangular {
                    VStack(alignment: .leading, spacing: 3) {
                        Label(pet.name, systemImage: pet.symbolName).font(.headline)
                        Text("\(pet.completed) of \(pet.scheduled) meals given").font(.caption)
                        ProgressView(value: Double(pet.completed), total: Double(max(1, pet.scheduled)))
                    }
                } else if family == .accessoryInline {
                    Label("\(pet.name): \(pet.completed)/\(pet.scheduled) meals", systemImage: pet.symbolName)
                } else if family == .systemSmall {
                    SmallPetCareCard(pet: pet, day: entry.date)
                } else {
                    homeCard(pet)
                }
            } else if family == .accessoryInline {
                Label("Open Pet Reminder", systemImage: "heart")
            } else if family == .accessoryCircular || family == .accessoryRectangular {
                Label("Choose a pet", systemImage: "heart")
                    .font(.caption)
            } else {
                EmptyCareView(hasSnapshot: entry.hasSnapshot, missingPet: entry.selectedID != nil)
            }
        }
        .widgetURL(entry.selectedPet?.url ?? URL(string: entry.hasSnapshot && entry.pets.isEmpty ? "petreminder://add" : "petreminder://home"))
        .containerBackground(for: .widget) { CareBackground() }
    }

    private func homeCard(_ pet: WidgetPet) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Link(destination: pet.url) {
                HStack(spacing: 12) {
                    PetPortrait(pet: pet, size: 52)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pet.name).font(.system(.title3, design: .rounded, weight: .bold))
                            .lineLimit(1).minimumScaleFactor(0.7)
                        Text(pet.scheduled > 0 && pet.completed == pet.scheduled
                             ? LocalizedStringKey("All fed. All loved.")
                             : LocalizedStringKey("\(pet.scheduled - pet.completed) meals to go"))
                            .monospacedDigit()
                            .contentTransition(.numericText())
                            .font(.caption).foregroundStyle(.secondary).lineLimit(2).minimumScaleFactor(0.75)
                    }
                    Spacer(minLength: 0)
                    CareRing(completed: pet.completed, total: pet.scheduled, size: 52)
                    Image(systemName: "chevron.forward")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
            Spacer(minLength: 0)
            HStack(spacing: 6) {
                if pet.morningScheduled {
                    MealToggle(pet: pet, meal: .morning, day: entry.date)
                }
                if pet.eveningScheduled {
                    MealToggle(pet: pet, meal: .evening, day: entry.date)
                }
            }
        }
    }
}

struct CareOverviewView: View {
    let entry: CareEntry
    @Environment(\.widgetFamily) private var family
    private var completed: Int { entry.pets.reduce(0) { $0 + $1.completed } }
    private var total: Int { entry.pets.reduce(0) { $0 + $1.scheduled } }
    private var visiblePets: [WidgetPet] { Array(entry.pets.prefix(family == .systemLarge ? 4 : 2)) }

    var body: some View {
        Group {
            if entry.pets.isEmpty {
                EmptyCareView(hasSnapshot: entry.hasSnapshot)
            } else if family == .systemSmall {
                SmallCareOverviewCard(entry: entry)
            } else {
                VStack(alignment: .leading, spacing: family == .systemLarge ? 8 : 4) {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Your little crew")
                                .font(.system(.headline, design: .rounded, weight: .bold))
                                .lineLimit(1).minimumScaleFactor(0.75)
                            Label {
                                Text(entry.date, format: .dateTime.weekday(.wide).month(.abbreviated).day())
                            } icon: {
                                Image(systemName: "heart").foregroundStyle(CareStyle.mint).widgetAccentable()
                            }
                            .font(.caption).foregroundStyle(.secondary)
                        }
                        Spacer(minLength: 6)
                        CareRing(completed: completed, total: total, size: family == .systemLarge ? 48 : 36)
                    }
                    ForEach(visiblePets) { pet in
                        Link(destination: pet.url) {
                            HStack(spacing: 10) {
                                PetPortrait(pet: pet, size: family == .systemLarge ? 44 : 30)
                                Text(pet.name).font(.system(.subheadline, design: .rounded, weight: .semibold))
                                    .lineLimit(1)
                                Spacer()
                                if pet.morningScheduled { mealDot(morning: true, fed: pet.morningFed) }
                                if pet.eveningScheduled { mealDot(morning: false, fed: pet.eveningFed) }
                                Image(systemName: "chevron.forward")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                    .accessibilityHidden(true)
                            }
                            .frame(maxWidth: .infinity, minHeight: family == .systemLarge ? 44 : 32, alignment: .leading)
                            .contentShape(.rect)
                        }
                        .buttonStyle(.plain)
                    }
                    if family == .systemLarge {
                        Spacer(minLength: 0)
                        HStack {
                            Text(completed == total ? LocalizedStringKey("Everyone's all fed.") : LocalizedStringKey("\(total - completed) meals to go"))
                                .contentTransition(.numericText())
                            Spacer(minLength: 2)
                            if entry.pets.count > visiblePets.count {
                                Text("+\(entry.pets.count - visiblePets.count) pets")
                            }
                        }.font(.caption2).foregroundStyle(.secondary).lineLimit(1)
                    }
                }
            }
        }
        .widgetURL(URL(string: entry.hasSnapshot && entry.pets.isEmpty ? "petreminder://add" : "petreminder://home"))
        .containerBackground(for: .widget) { CareBackground() }
    }

    private func mealDot(morning: Bool, fed: Bool) -> some View {
        Image(systemName: fed ? "checkmark.circle.fill" : morning ? "sun.max" : "moon")
            .font(.system(.subheadline, weight: .semibold))
            .foregroundStyle(fed ? CareStyle.mint : .secondary)
            .widgetAccentable(fed)
            .accessibilityLabel(morning ? Text("Morning") : Text("Evening"))
            .accessibilityValue(fed ? Text("Fed") : Text("Not fed"))
    }
}

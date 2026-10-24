import SwiftData
import Shared

@MainActor
public enum PreviewData {
    public static let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
            let container = try ModelContainer(for: Pet.self, configurations: config)
            let sampleData: [Pet] = Pet.previews

            sampleData.forEach {
                container.mainContext.insert($0)
            }

            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()

    public static let emptyContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true, cloudKitDatabase: .none)
            let container = try ModelContainer(for: Pet.self, configurations: config)
            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
}

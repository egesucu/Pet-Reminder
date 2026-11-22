import CoreTransferable
import Shared
import SharedUI
import SwiftUI
import UniformTypeIdentifiers

private nonisolated struct DroppedPetPhoto: Transferable {
    let data: Data
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(importedContentType: .image) { data in
            DroppedPetPhoto(data: data)
        }
    }
}

private struct PetPhotoDrop: ViewModifier {
    @Binding var data: Data?
    @State private var isTargeted = false
    @State private var showError = false
    @State private var pendingPhoto: PendingPhoto?

    private struct PendingPhoto {
        let id = UUID()
        let data: Data
    }

    func body(content: Content) -> some View {
        content
            .contentShape(.rect)
            .dropDestination(for: DroppedPetPhoto.self) { photos, _ in
                guard let photo = photos.first else { return false }
                pendingPhoto = PendingPhoto(data: photo.data)
                return true
            } isTargeted: { isTargeted = $0 }
            .task(id: pendingPhoto?.id) {
                guard let request = pendingPhoto else { return }
                let result = await PetPhotoImport.prepare(request.data)
                guard !Task.isCancelled, pendingPhoto?.id == request.id else { return }
                pendingPhoto = nil
                if let result { data = result } else { showError = true }
            }
            .overlay {
                if pendingPhoto != nil {
                    ProgressView().allowsHitTesting(false)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: .radius16)
                    .stroke(isTargeted ? Color.accent : .clear, lineWidth: 3)
                    .allowsHitTesting(false)
            }
            .accessibilityHint(Text(SharedStrings.resource("Drop a photo here")))
            .alert(SharedStrings.resource("Could not load photo"), isPresented: $showError) { } message: {
                Text(SharedStrings.resource("This photo could not be processed. Please try another image."))
            }
    }
}

extension View {
    func petPhotoDrop(data: Binding<Data?>) -> some View { modifier(PetPhotoDrop(data: data)) }
}

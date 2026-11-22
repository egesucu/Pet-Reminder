import Foundation
import Shared
import SharedUI
import SwiftData
import SwiftUI

struct PetNotes: View {
    let pet: Pet

    @Environment(\.modelContext) private var modelContext
    @State private var showAddNote = false
    @State private var showSaveError = false

    private var notes: [PetNote] {
        (pet.notes ?? []).sorted { $0.createdAt > $1.createdAt }
    }

    var body: some View {
        Group {
            if notes.isEmpty {
                ContentUnavailableView(SharedStrings.resource("No Notes"), systemImage: "note.text")
            } else {
                List {
                    let displayedNotes = notes
                    ForEach(displayedNotes) { note in
                        Text(verbatim: note.text)
                    }
                    .onDelete { offsets in
                        removeNotes(offsets.map { displayedNotes[$0] })
                    }
                }
            }
        }
        .navigationTitle(SharedStrings.resource("Notes"))
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(SharedStrings.resource("Add Note")) {
                    showAddNote = true
                }
            }
            if !notes.isEmpty {
                ToolbarItem(placement: .secondaryAction) {
                    EditButton()
                }
            }
        }
        .sheet(isPresented: $showAddNote) {
            AddPetNote(pet: pet)
        }
        .alert(SharedStrings.saveFailed, isPresented: $showSaveError) { }
    }

    private func removeNotes(_ notes: [PetNote]) {
        do {
            try modelContext.transaction {
                for note in notes {
                    modelContext.delete(note)
                }
            }
        } catch {
            modelContext.rollback()
            showSaveError = true
        }
    }
}

private struct AddPetNote: View {
    let pet: Pet

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var draft = ""
    @State private var showDiscard = false
    @State private var showSaveError = false

    private var noteText: String {
        draft.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField(SharedStrings.resource("Note"), text: $draft, axis: .vertical)
                    .lineLimit(4...10)
            }
            .navigationTitle(SharedStrings.resource("Add Note"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(SharedStrings.cancelTitle, role: .cancel) {
                        if draft.isEmpty { dismiss() } else { showDiscard = true }
                    }
                    .keyboardShortcut(.cancelAction)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(SharedStrings.save, role: .confirm, action: save)
                        .keyboardShortcut(.return, modifiers: .command)
                        .disabled(noteText.isEmpty)
                }
            }
        }
        .interactiveDismissDisabled(!draft.isEmpty)
        .confirmDiscardChanges(isPresented: $showDiscard, discard: dismiss.callAsFunction)
        .alert(SharedStrings.saveFailed, isPresented: $showSaveError) { }
    }

    private func save() {
        guard !noteText.isEmpty else { return }

        do {
            try modelContext.transaction {
                modelContext.insert(PetNote(text: noteText, pet: pet))
            }
            dismiss()
        } catch {
            modelContext.rollback()
            showSaveError = true
        }
    }
}

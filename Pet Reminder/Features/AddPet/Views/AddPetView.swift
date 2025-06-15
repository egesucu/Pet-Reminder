//
//  AddPetView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 10.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import OSLog
import SwiftData
import Shared
import SFSafeSymbols

struct AddPetView: View {
    
    @State private var position = 0
    @State private var pet: Pet = .init()
    @State private var selectedImageData: Data?
    
    @State private var feedSelection: FeedSelection = .both
    @State private var morningFeed: Date = .eightAM
    @State private var eveningFeed: Date = .eightPM
    
    @State private var nameIsValid = false
    @State private var petExists = false
    @State private var saveFailed = false
    @State private var saveSuccess = false
    
    @Environment(NotificationManager.self) private var notificationManager: NotificationManager
    
    @Environment(\.modelContext)
    private var modelContext
    
    var onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void = {}) {
        self.onDismiss = onDismiss
    }
    
    var petCanBeSaved: Bool {
        nameIsValid && !petExists
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                topActionsView
                stepsView
            }
        }
        .background(.ultraThinMaterial)
        .sensoryFeedback(.error, trigger: saveFailed)
        .sensoryFeedback(.success, trigger: saveSuccess)
        .alert(.saveFailed, isPresented: $saveFailed) {
            Button("OK", action: onDismiss)
            Button("Retry", action: save)
        }
        .alert("Save Successful", isPresented: $saveSuccess) {
            Button("OK", action: onDismiss)
        }
    }
    
    private var topActionsView: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemSymbol: .xCircleFill)
                    .font(.title)
                    .foregroundColor(.red)
            }
            Spacer()
            trailingButton()
        }
        .padding(.horizontal)
        .frame(maxHeight: 80)
    }
    
    private var stepsView: some View {
        TabView(selection: $position) {
            PetNameTextField(
                name: $pet.name,
                nameIsValid: $nameIsValid,
                petExists: $petExists
            )
            .padding(.horizontal)
            .tag(0)
            
            PetBirthdayView(birthday: $pet.birthday)
                .padding(.horizontal)
                .tag(1)
            
            VStack(spacing: 20) {
                Text(.petKindText)
                    .font(.headline)
                    .foregroundStyle(.black)
                
                Picker(selection: $pet.type) {
                    ForEach(PetType.allCases, id: \.self) { type in
                        Logger.pets.info("Type is \(type.localizedName)")
                        return Text(verbatim: type.localizedName)
                            .foregroundStyle(.black)
                    }
                } label: {
                    Text(.petKindText)
                        .foregroundStyle(.black)
                }
                .pickerStyle(.segmented)
                .colorMultiply(.white)
                PetImageView(
                    selectedImageData: $selectedImageData,
                    petType: $pet.type
                )
            }
            .padding(.horizontal)
            .tag(2)
            
            VStack(spacing: 10) {
                NotificationSelectView(feedSelection: $feedSelection)
                PetNotificationSelectionView(
                    feedSelection: $feedSelection,
                    morningFeed: $morningFeed,
                    eveningFeed: $eveningFeed
                )
            }
            .padding(.horizontal)
            .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .onChange(of: position) { oldValue, newValue in
            Logger.pets.debug("Tab changed from \(oldValue) to \(newValue)")
        }
    }

    
    @ViewBuilder
    private func trailingButton() -> some View {
        Button {
            position == 3 ? save() : swipeLeft()
        } label: {
            Image(systemSymbol: defineTrailingButtonImage())
            .font(.title)
            .foregroundStyle(defineForegroundStyle())
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: petCanBeSaved)
            
        }
        .disabled(!petCanBeSaved && position == 0)
    }
    
    private func defineForegroundStyle() -> Gradient {
        if !petCanBeSaved && position == 0 {
            return Gradient(colors: [.gray])
        } else {
            return Gradient(colors: [.accent,.green])
        }
    }
    
    private func defineTrailingButtonImage() -> SFSymbol {
        if position == 3 {
            if petCanBeSaved {
               return .squareAndArrowDownFill
            } else {
                return .squareAndArrowDown
            }
        } else {
            return .arrowRightCircle
        }
    }
}

#Preview {
    AddPetView()
        .environment(NotificationManager.shared)
}


// MARK: - Actions
extension AddPetView {
    private func createNotifications() async {
        
        switch feedSelection {
        case .both:
            await notificationManager.createNotification(of: pet.name, with: NotificationType.morning, date: morningFeed)
            await notificationManager.createNotification(of: pet.name, with: NotificationType.evening, date: eveningFeed)
        case .morning:
            await notificationManager.createNotification(of: pet.name, with: NotificationType.morning, date: morningFeed)
        case .evening:
            await notificationManager.createNotification(of: pet.name, with: NotificationType.evening, date: eveningFeed)
        }
        
        await notificationManager.createNotification(of: pet.name, with: NotificationType.birthday, date: pet.birthday)
    }
    
    private func swipeLeft() {
        withAnimation {
            position += 1
        }
    }
    
    private func save() {
        /// If the pet can't be saved, we show the alert & navigate the user into the first step to change the name.
        guard petCanBeSaved else {
            saveFailed.toggle()
            position = 0
            return
        }
        Task {
            pet.feedSelection = feedSelection
            modelContext.insert(pet)
            await createNotifications()
            
            do {
                try modelContext.save()
                saveSuccess.toggle()
            } catch {
                Logger.pets.error("Could not saved the pet: \(error.localizedDescription)")
                saveFailed.toggle()
            }
        }
    }
}

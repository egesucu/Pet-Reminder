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
    @State private var feedTime: FeedSelection = .both
    @State private var nameIsFilledCorrectly = false
    @State private var pet: Pet = .init()
    @State private var selectedImageData: Data?
    @State private var morningFeed: Date = .eightAM
    @State private var eveningFeed: Date = .eightPM
    
    @State private var saveFailed = false
    @State private var saveSuccess = false
    
    @Environment(NotificationManager.self) private var notificationManager: NotificationManager
    
    @Environment(\.modelContext)
    private var modelContext
    
    var onDismiss: () -> Void
    
    init(onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        NavigationStack {
            topActionsView
            stepsView
        }
        .background(
            Color.gray.opacity(0.3)
        )
        .sensoryFeedback(.error, trigger: saveFailed)
        .sensoryFeedback(.success, trigger: saveSuccess)
        .alert("Save Failed", isPresented: $saveFailed) {
            Button("OK", action: onDismiss)
            Button("Retry", action: save)
        }
    }
    
    private var topActionsView: some View {
        HStack {
            Button(action: onDismiss) {
                Image(systemSymbol: .xCircleFill)
                    .font(.title)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red,.orange.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            Spacer()
            saveButton()
        }
        .padding(.horizontal)
    }
    
    private var stepsView: some View {
        TabView(selection: $position) {
            PetNameTextField(
                name: $pet.name,
                nameIsFilledCorrectly: $nameIsFilledCorrectly
            )
            .padding()
            .tag(0)
            
            PetBirthdayView(birthday: $pet.birthday)
                .padding()
                .tag(1)
            
            VStack {
                Text("Which kind of the Pet you've got?")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Picker(selection: $pet.type) {
                    ForEach(PetType.allCases, id: \.self) {
                        Text($0.name)
                            .foregroundStyle(.white)
                    }
                } label: {
                    Text("Which kind of the Pet you've got?")
                        .foregroundStyle(.white)
                }
                .pickerStyle(.segmented)
                .padding()
                .colorMultiply(.white)
                PetImageView(
                    selectedImageData: $selectedImageData,
                    petType: $pet.type
                )
                .padding()
            }
            .tag(2)
            
            VStack {
                NotificationSelectView(dayType: $feedTime)
                    .padding()
                PetNotificationSelectionView(
                    dayType: $feedTime,
                    morningFeed: $morningFeed,
                    eveningFeed: $eveningFeed
                )
                .padding()
            }
            .tag(3)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .onChange(of: position) { oldValue, newValue in
            Logger.pets.debug("Tab changed from \(oldValue) to \(newValue)")
        }
    }
    
    private func save() {
        Task {
            modelContext.insert(pet)
            await createNotifications()
            
            do {
                try modelContext.save()
                saveSuccess.toggle()
                onDismiss()
            } catch {
                Logger.pets.error("Could not saved the pet: \(error.localizedDescription)")
                saveFailed.toggle()
                onDismiss()
            }
        }
    }
    
    private func saveButton() -> some View {
        Button(action: save) {
            Image(
                systemSymbol: nameIsFilledCorrectly
                ? .squareAndArrowDownFill
                : .squareAndArrowDown
            )
            .font(.title)
            .foregroundStyle(
                nameIsFilledCorrectly
                ? Gradient(colors: [.accent,.green])
                : Gradient(colors: [.gray])
            )
            .scaleEffect(nameIsFilledCorrectly ? 1.2 : 1.0)
            .opacity(nameIsFilledCorrectly ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.5), value: nameIsFilledCorrectly)
        }
        .disabled(!nameIsFilledCorrectly)
    }
    
    private func createNotifications() async {
        
        switch feedTime {
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
}

#Preview {
    AddPetView(){}
}

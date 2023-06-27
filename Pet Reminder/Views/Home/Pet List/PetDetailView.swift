//
//  PetDetailView.swift
//  Pet Reminder
//
//  Created by egesucu on 31.07.2021.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import SwiftData

struct PetDetailView: View {

    var pet: Pet
    var feed: Feed?
    @State private var morningOn = false
    @State private var eveningOn = false
    @State private var showFeedHistory = false
    @State private var showVaccines = false

//    @AppStorage(Strings.tintColor) var tintColor = Color(uiColor: .systemGreen)

    let feedback = UINotificationFeedbackGenerator()

    var body: some View {
        VStack {
            ESImageView(data: pet.image)
                .padding([.top, .leading, .trailing], 20)
                .frame(
                    minWidth: 50,
                    idealWidth: 100,
                    maxWidth: 200,
                    minHeight: 50,
                    idealHeight: 100,
                    maxHeight: 200,
                    alignment: .center
                )
            Spacer()
            HStack(spacing: 30) {
//                switch pet.selection {
//                case .morning:
//                    MorningCheckboxView(morningOn: $morningOn)
//                        .onChange(of: morningOn, {
//                            feedback.notificationOccurred(.success)
//                            updateFeed(type: .morning, value: morningOn)
//                            self.save()
//                        })
//                        .onTapGesture {
//                            morningOn.toggle()
//                        }
//                case .evening:
//                    EveningCheckboxView(eveningOn: $eveningOn)
//                        .onChange(of: eveningOn, {
//                            feedback.notificationOccurred(.success)
//                            updateFeed(type: .evening, value: eveningOn)
//                            self.save()
//                        })
//                        .onTapGesture {
//                            eveningOn.toggle()
//                        }
//                case .both:
//                    MorningCheckboxView(morningOn: $morningOn)
//                        .onChange(of: morningOn, {
//                            feedback.notificationOccurred(.success)
//                            updateFeed(type: .morning, value: morningOn)
//                            self.save()
//                        })
//                        .onTapGesture {
//                            morningOn.toggle()
//                        }
//                    EveningCheckboxView(eveningOn: $eveningOn)
//                        .onChange(of: eveningOn, {
//                            feedback.notificationOccurred(.success)
//                            updateFeed(type: .evening, value: eveningOn)
//                            self.save()
//                        })
//                        .onTapGesture {
//                            eveningOn.toggle()
//                        }
//                }
            }
            .padding(.bottom, 50)

            HStack {
                Button {
                    showFeedHistory.toggle()
                } label: {
                    Label("feeds_title", systemImage: "fork.knife.circle.fill")
                }
                .buttonStyle(.bordered)
                .tint(Color.accentColor)
                Button {
                    showVaccines.toggle()
                } label: {
                    Label("vaccines_title", systemImage: "syringe.fill")
                }
                .buttonStyle(.bordered)
                .tint(.blue)
            }

            Spacer()
        }
        .onAppear {
            getLatestFeed()
        }
        .fullScreenCover(isPresented: $showFeedHistory, content: {
            FeedHistory(feeds: filterFeeds())
        })
        .fullScreenCover(isPresented: $showVaccines, content: {
            VaccineHistoryView(pet: pet)
        })
        .navigationTitle(Text("pet_name_title \(pet.name ?? "")"))
    }
// swiftlint: disable trailing_whitespace
    func filterFeeds() -> [Feed] {
        return pet.feeds?.filter({ feed in
            feed.morningFedStamp != nil || feed.eveningFedStamp != nil
        }).sorted(by: {
            $0.feedDate ?? .now > $1.feedDate ?? .now
        }) ?? []
        
    }
// swiftlint: enable trailing_whitespace
    func updateFeed(type: NotificationSelection, value: Bool) {
        if let feeds = pet.feeds {
            if feeds.filter({ Calendar.current.isDateInToday($0.feedDate ?? .now)}).count == 0 {
                let feed = Feed()
                switch type {
                case .morning:
                    feed.morningFedStamp = value ? .now : nil
                    feed.morningFed = value
                case .evening:
                    feed.eveningFedStamp = value ? .now : nil
                    feed.eveningFed = value
                default:
                    break
                }
                pet.feeds?.append(feed)
            } else {
                if let lastFeed = feeds.last {
                    switch type {
                    case .morning:
                        lastFeed.morningFedStamp = value ? .now : nil
                        lastFeed.morningFed = value
                    case .evening:
                        lastFeed.eveningFedStamp = value ? .now : nil
                        lastFeed.eveningFed = value
                    default:
                        break
                    }
                    if value {
                        lastFeed.feedDate = .now
                    }
                }
            }
        }
    }

    func getLatestFeed() {
        if let feeds = pet.feeds {
            if let lastFeed = feeds.last {
                if let date = lastFeed.feedDate {
                    if Calendar.current.isDateInToday(date) {
                        // We have a feed.
                        morningOn = lastFeed.morningFed ?? false
                        eveningOn = lastFeed.eveningFed ?? false
                    }
                }
            }
        }
    }
}

// #Preview {
//    MainActor.assumeIsolated {
//        PetDetailView(pet: PreviewSampleData.previewPet)
//            .modelContainer(PreviewSampleData.container)
//    }
//    
// }

struct PetDetailView_Previews: PreviewProvider {
    static var previews: some View {

        return NavigationView {
            PetDetailView(pet: PreviewSampleData.previewPet)
        }.navigationViewStyle(.stack)
            .previewInterfaceOrientation(.portrait)
    }
}

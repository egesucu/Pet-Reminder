//
//  PetDetailView.swift
//  Pet Reminder
//
//  Created by egesucu on 31.07.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import CoreData

struct PetDetailView: View {
    
    var pet : Pet
    var feed: Feed?
    @State private var morningOn = false
    @State private var eveningOn = false
    @State private var showFeedHistory = false
    
    let feedback = UINotificationFeedbackGenerator()
    var context: NSManagedObjectContext
    
    var body: some View {
        VStack{
            ESImageView(data: pet.image)
                .padding([.top,.leading,.trailing],20)
                .frame(minWidth: 50, idealWidth: 150, maxWidth: 350, minHeight: 50, idealHeight: 150, maxHeight: 350, alignment: .center)
            Spacer()
            HStack(spacing: 30){
                switch pet.selection{
                case .morning:
                    MorningCheckboxView(morningOn: $morningOn)
                        .onChange(of: morningOn, perform: { value in
                            feedback.notificationOccurred(.success)
                            updateFeed(type: .morning, value: value)
                            self.save()
                        })
                        .onTapGesture {
                            morningOn.toggle()
                        }
                case .evening:
                    EveningCheckboxView(eveningOn: $eveningOn)
                        .onChange(of: eveningOn, perform: { value in
                            feedback.notificationOccurred(.success)
                            updateFeed(type: .evening, value: value)
                            self.save()
                        })
                        .onTapGesture {
                            eveningOn.toggle()
                        }
                case .both:
                    MorningCheckboxView(morningOn: $morningOn)
                        .onChange(of: morningOn, perform: { value in
                            feedback.notificationOccurred(.success)
                            updateFeed(type: .morning, value: value)
                            self.save()
                        })
                        .onTapGesture {
                            morningOn.toggle()
                        }
                    EveningCheckboxView(eveningOn: $eveningOn)
                        .onChange(of: eveningOn, perform: { value in
                            feedback.notificationOccurred(.success)
                            updateFeed(type: .evening, value: value)
                            self.save()
                        })
                        .onTapGesture {
                            eveningOn.toggle()
                        }
                }
            }
            .padding(.bottom,50)
            
            Button {
                showFeedHistory.toggle()
            } label: {
                Text("Feed History")
            }
            .buttonStyle(.borderedProminent)
            .font(.largeTitle)
            .tint(Color.accentColor)

            Spacer()
        }
        .onAppear{
            getLatestFeed()
        }
        .sheet(isPresented: $showFeedHistory, content: {
            FeedHistory(feeds: filterFeeds(), context: context)
        })
        .navigationTitle(Text("pet_name_title \(pet.name ?? "")"))
    }
    
    func filterFeeds() -> [Feed]{
        let feedSet = pet.feeds
        if let feeds = feedSet?.allObjects as? [Feed]{
            return feeds.filter({ $0.morningFedStamp != nil || $0.eveningFedStamp != nil }).sorted(by: { $0.feedDate ?? .now > $1.feedDate ?? .now })
        }
        return []
    }
    
    func updateFeed(type: Selection, value: Bool){
        if let feedSet = pet.feeds,
           let feeds = feedSet.allObjects as? [Feed]{
            if feeds.count > 0 {
                if let lastFeed = feeds.last{
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
                }
            }
        }
    }
    
    func getLatestFeed(){
        if let feedSet = pet.feeds,
           let feeds = feedSet.allObjects as? [Feed]{
            if feeds.count > 0 {
                if let lastFeed = feeds.last{
                    if let date = lastFeed.feedDate{
                        if Calendar.current.isDateInToday(date){
                            // We have a feed.
                            morningOn = lastFeed.morningFed
                            eveningOn = lastFeed.eveningFed
                        }
                    }
                }
            }
        }
    }
    
    func save(){
        PersistenceController.shared.save()
    }
}

struct PetDetailView_Previews: PreviewProvider {
    static var previews: some View {
        
        let persistence = PersistenceController.preview
        
        let demo = Pet(context: persistence.container.viewContext)
        demo.name = "Viski"
        let feed = Feed(context: persistence.container.viewContext)
        demo.addToFeeds(feed)
        
        return NavigationView {
            PetDetailView(pet: demo, context: persistence.container.viewContext)
        }.navigationViewStyle(.stack)
            .previewInterfaceOrientation(.portrait)
    }
}

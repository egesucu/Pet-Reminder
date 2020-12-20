//
//  HomeView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.12.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI
import CoreData
import EventKit

struct HomeView: View {
    
    @Environment(\.managedObjectContext)
    private var viewContext
    
    @FetchRequest(sortDescriptors: [])
    private var pets : FetchedResults<Pet>
    
    @State private var selectedPet : Pet?
    @State private var allPetsRemoved = false
    @State private var showAddEvent = false
    
    
    var body: some View {
        
        ScrollView {
            VStack(alignment: .leading){
                Text("Hello \(selectedPet?.name ?? pets.first!.name!)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding([.top,.bottom],30)
                    .padding(.leading)
                Text("Your Pets")
                    .font(.largeTitle)
                    .padding()
                ScrollView(.horizontal){
                    HStack {
                        ForEach(pets){ pet in
                            CircularAnimalView(pet: pet)
                                .onTapGesture {
                                    selectPet(pet)
                                }
                                .contextMenu(ContextMenu(menuItems: {
                                    Button(action: {
                                        withAnimation{
                                            self.removePet(pet: pet)
                                        }
                                    }, label: {
                                        Text("Remove Pet")
                                        Image(systemName: "trash")
                                    })
                                    Button(action: {}, label: {
                                        Text("Cancel")
                                        Image(systemName: "xmark")
                                    })
                                }))
                                .sheet(isPresented: $allPetsRemoved, content: {
                                    HelloView()
                                })
                        }
                        .padding()
                    }
                }
                
                PetDetailView(pet: selectedPet ?? pets.first!)
                
                Text("Daily Routine")
                    .font(.largeTitle)
                    .padding()
                if let firstPet = pets.first {
                    DailyRoutineView(selectedPet: selectedPet ?? firstPet)
                }
                HStack{
                    Text("Up Next")
                        .font(.largeTitle)
                        .padding()
                    Spacer()
                    Button(action: {
                        showAddEvent.toggle()
                    }, label: {
                        Text("Add Event")
                            .padding()
                            .background(Color(.systemGreen))
                            .foregroundColor(.white)
                            .cornerRadius(60)
                            .shadow(color: Color(.systemGray4), radius: 8, x: 4, y: 4)
                    })
                    .padding(.trailing)
                    .sheet(isPresented: $showAddEvent) {
                        AddEventView()
                    }
                }
                EventsView()
                
                Spacer()
                
            }
        }
        
    }
    
    func selectPet(_ pet: Pet){
        selectedPet = pet
        
    }
    
    func removePet(pet: Pet){
        viewContext.delete(pet)
        try? viewContext.save()
        
        if let firstPet = pets.first{
            selectedPet = firstPet
        } else if pets.isEmpty {
            UserDefaults.standard.removeObject(forKey: "petSaved")
            allPetsRemoved = true
            
        }
        
    }
    
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
        
        
    }
}

struct CircularAnimalView : View {
    
    var pet : Pet
    
    var body: some View {
        
        VStack{
            if let imageData = pet.image,
               let uiImage = UIImage(data: imageData){
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50, alignment: .center)
                    .padding()
                    .background(Color(.systemBackground))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(.label),lineWidth: 4))
                    .shadow(color: Color(.systemGray4), radius: 4, x: 4, y: 8)
                
            } else {
                Image("default-animal")
            }
            Text(pet.name ?? "Error Name")
        }
        
    }
    
}


struct PetDetailView: View {
    
    var pet : Pet
    
    var body: some View{
        
        HStack{
            Spacer()
            if let data = pet.image,
               let image = UIImage(data: data){
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(minWidth: 30, maxWidth: 100, minHeight: 30, maxHeight: 100)
                    .padding()
                    .overlay(Circle().stroke(Color(.label),lineWidth: 4))
                    .shadow(color: Color(.systemGray4), radius: 4, x: 4, y: 8)
                
            }
            Spacer()
        }
        
        
    }
    
}

struct DailyRoutineView : View {
    
    var selectedPet : Pet
    @Environment(\.managedObjectContext)
    private var viewContext
    
    @State private var morningSelected = false
    @State private var eveningSelected = false
    
    
    var body: some View{
        
        HStack(alignment: .center, spacing: 20, content: {
            Spacer()
            if selectedPet.morningTime != nil{
                ZStack {
                    Rectangle().fill(Color(.systemYellow))
                        .frame(width: 100, height: 92, alignment: .center)
                        .cornerRadius(15)
                        .shadow(color: Color(.systemGray4), radius: 8, x: 4, y: 4)
                    VStack{
                        Text("Morning")
                        Toggle(isOn: Binding<Bool>(
                            get: {
                                selectedPet.morningFed
                            } ,
                            set: {
                                selectedPet.morningFed = $0
                                try? viewContext.save()
                            }
                            
                            
                        ), label: {
                            Text("")
                        }).labelsHidden()
                        
                        
                    }
                    
                    .padding(20)
                }
            }
            Spacer()
            if selectedPet.eveningTime != nil {
                ZStack {
                    Rectangle().fill(Color(.systemBlue))
                        .frame(width: 100, height: 92, alignment: .center)
                        .cornerRadius(15)
                        .shadow(color: Color(.systemGray4), radius: 8, x: 4, y: 4)
                    VStack{
                        Text("Evening")
                        Toggle(isOn: Binding<Bool>(
                            get: {
                                selectedPet.eveningFed
                            } ,
                            set: {
                                selectedPet.eveningFed = $0
                                try? viewContext.save()
                            }
                            
                            
                        ), label: {
                            Text("")
                        }).labelsHidden()
                        .background(Color.blue)
                    }
                    
                    .padding(20)
                }
            }
            Spacer()
        })
        
    }
    
}

struct EventsView : View {
    
    @ObservedObject var eventVM = EventList()
    
    
    var body: some View{
        
        VStack(alignment: .center){
            if eventVM.events.isEmpty {
                HStack {
                    Spacer()
                    Text("There is no event")
                        .font(.body)
                        .padding()
                    Spacer()
                }
                
            } else {
                ForEach(eventVM.events, id: \.self){ event in
                    ZStack{
                        Rectangle()
                            .fill(Color(.systemGreen))
                            .cornerRadius(15)
                            .shadow(color: Color(.systemGray4), radius: 8, x: 4, y: 4)
                        EventView(event: event, startDateInString: eventVM.convertDateToString(date: event.startDate), endDateInString: eventVM.convertDateToString(date: event.endDate))
                        
                    }
                }
            }
        }
        
    }
    
    
}

struct EventView : View{
    
    var event : EKEvent
    
    var startDateInString : String
    var endDateInString : String
    
    var body: some View{
        VStack{
            Text(event.title)
                .font(.largeTitle)
            HStack {
                Text(startDateInString)
                    .font(.body)
                Text(endDateInString)
                    .font(.body)
            }
        }
    }
}

struct AddEventView : View {
    
    @State private var eventName = ""
    @State private var eventStartDate = Date()
    @State private var eventEndDate = Date()
    @ObservedObject var eventVM = EventList()
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View{
        
        ZStack(alignment: .topLeading) {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
                eventName = ""
            }, label: {
                Image(systemName: "xmark")
                    .frame(width: 30, height: 30)
                    
                    .offset(x: 10 , y: 10)
                    
                    
                    .foregroundColor(.black)
            })
            VStack{
                    Text("Event Name")
                        .font(.largeTitle)
                        .padding(.top)
                    TextField("Type to add...", text: $eventName)
                        .labelsHidden()
                        .padding()
                        .cornerRadius(15)
                        .shadow(color: Color(.systemGray4), radius: 8, x: 4, y: 4)
                
                .padding()
                Spacer()
                Text("Event Start Date")
                    .font(.headline).padding()
                DatePicker("Start Date", selection: $eventStartDate).labelsHidden().padding()
                Text("Event End Date")
                    .font(.headline).padding()
                DatePicker("End Date", selection: $eventEndDate).labelsHidden().padding()
                
                Spacer()
                Button(action: {
                    self.eventVM.saveEvent(name: eventName, start: eventStartDate, end: eventEndDate)
                    self.presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("Save Event")
                        .padding()
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .background(Color(.systemGreen))
                        .cornerRadius(60)
                })
                .padding()
                .cornerRadius(60)
                .shadow(color: Color(.systemGray4), radius: 8, x: 4, y: 4)
                .padding()

            }
        }
        
    }
}

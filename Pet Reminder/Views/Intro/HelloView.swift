//
//  HelloView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.06.2020.
//  Copyright © 2020 Ege Sucu. All rights reserved.
//

import SwiftUI

struct MainView: View {
    
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(entity: Pet.entity(), sortDescriptors: [])
    var pets : FetchedResults<Pet>
    
    var body: some View{
        
        ZStack{
            if pets.count > 0 {
                HomeManagerView().environment(\.managedObjectContext, context)
            } else {
                HelloView().environment(\.managedObjectContext, context)
            }
            
        }
        .onAppear(perform: {
            resetLogic()
        })
    }
    
    func resetLogic() {
        
        let today = UserDefaults.standard.object(forKey: "today") as? Date
        
        if let today = today{
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            
            let first = dateFormatter.string(from: today)
            let second = dateFormatter.string(from: Date())
    
            if first != second{
                removePetFeeds()
                UserDefaults.standard.setValue(Date(), forKey: "today")
                print("Pet Choices are removed. Date is different")
            } else {
                print("Pet Choices are not removed. Date is same.")
            }
            
        } else {
            UserDefaults.standard.setValue(Date(), forKey: "today")
            print("Pet Choices are not removed. Date does not exist.")
        }
        
    }
    
    
    func removePetFeeds(){
        
        DispatchQueue.main.async {
            for pet in pets{
                pet.morningFed = false
                pet.eveningFed = false
            }
            do {
                try context.save()
            } catch {
                print(error)
            }
        }
    }

}

struct HelloView: View {
    
    @State private var showSetup = false
    
    var body: some View {
        VStack(alignment: .center) {
            Image("pet-reminder")
                .resizable()
                .scaledToFit()
                .padding([.top,.bottom])
            Text("Welcome-Slogan")
                .padding([.top,.bottom])
                .font(.title)
            Spacer()
            Text("Welcome-Slogan-2")
                .padding([.top,.bottom])
                .font(.body)
            Spacer()
            Button {
                self.showSetup.toggle()
            } label: {
                
                Label("Add Pet", systemImage: "plus.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.white)
            }
            .padding()
            .background(Capsule().fill(Color(.systemGreen)))
            .shadow(radius: 10)
            .sheet(isPresented: $showSetup) {
                // some reload method to get petCount, ondismiss
            } content: {
                SetupNameView()
            }

        }.padding()
    }
    
}

struct HelloView_Previews: PreviewProvider {
    static var previews: some View {
        Group{
           MainView()
        }
        
    }
}



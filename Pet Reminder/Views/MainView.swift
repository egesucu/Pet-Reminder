//
//  MainView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 15.08.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI
import CloudKit

struct MainView: View {
    
    @Environment(\.managedObjectContext) private var context
    @FetchRequest(entity: Pet.entity(), sortDescriptors: [])
    var pets : FetchedResults<Pet>
    @State private var alertShown = false
    @State private var alertText = ""
    
    var body: some View{
        
        ZStack{
            
            if pets.underestimatedCount > 0 {
                HomeManagerView().environment(\.managedObjectContext, context)
            } else {
                HelloView().environment(\.managedObjectContext, context)
            }
            
        }
        .alert(isPresented: $alertShown, content: {
            Alert(title: Text("Error"), message: Text(alertText), primaryButton: .default(Text("Try Again"), action: {
                runBackgroundCheck()
            }), secondaryButton: .cancel(Text("Cancel")))
        })
        .onAppear {
            runBackgroundCheck()
            resetLogic()
        }
    }
    
    func runBackgroundCheck(){
        checkData { result in
            switch result{
            case .success(_):
                print("Okey")
            case .failure(let error):
                self.alertText = error.localizedDescription
                self.alertShown.toggle()
                
                
            }
        }
    }
    
    
    func checkData(completion: @escaping (Result<Bool,IcloudError>) -> Void){
        
        var isIcloudAvailable = false
        
        CKContainer.default().accountStatus { status, error in
            if let error = error {
                completion(.failure(.unknownError(error.localizedDescription)))
            }
            
            switch status{
            case .available:
                isIcloudAvailable = true
                break
            case .noAccount:
                completion(.failure(.noIcloud))
            case .restricted:
                completion(.failure(.restricted))
            case .couldNotDetermine:
                completion(.failure(.icloudUnavailable))
            @unknown default:
                completion(.failure(.unknownError(error?.localizedDescription ?? "")))
            }
        }
        
        if isIcloudAvailable{
            if NSUbiquitousKeyValueStore.default.bool(forKey: "petSaved"){
                completion(.success(true))
            } else {
                completion(.failure(.unknownError("")))
            }
        } else {
            completion(.failure(.unknownError("iCloud is not enabled.")))
        }
        
        
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

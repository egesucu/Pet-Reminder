//
//  AppRootView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 25.02.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct AppRootView: View {
    
    @FetchRequest(entity: Pet.entity(), sortDescriptors: [])
    var results : FetchedResults<Pet>
    @Environment(\.managedObjectContext)
    private var viewContext
    
    
    var helloView : some View {
        HelloView().environment(\.managedObjectContext, viewContext)
    }
    
    var rootView : some View  {
        RootView().environment(\.managedObjectContext, viewContext)
    }
    
    var body: some View {
        
        
        Group{
            
            results.count > 0 ? AnyView(rootView) : AnyView(helloView)
            
        }
        
        
        
    }
    
    
    
    
    
}


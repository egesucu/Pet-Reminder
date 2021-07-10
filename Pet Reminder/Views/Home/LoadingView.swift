//
//  LoadingView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.12.2020.
//  Copyright © 2020 Softhion. All rights reserved.
//

import SwiftUI

struct LoadingView: View{

    var body: some View {
        
        VStack{
            Text("Pets are coming 🐶").font(.title)
            ActivityIndicator(isAnimating: .constant(true), style: .large)
        }
        
        
    }

}

struct LoadingView_Previews : PreviewProvider{
    
    static var previews: some View{
        Group {
            LoadingView()
        }
    }
}

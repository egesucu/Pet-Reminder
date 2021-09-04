//
//  EmptyEventView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 4.09.2021.
//  Copyright © 2021 Softhion. All rights reserved.
//

import SwiftUI

struct EmptyEventView: View {
    var body: some View {
        HStack {
            Spacer()
            Text("There is no event")
                .font(.headline)
                .padding()
            Spacer()
        }
    }
}

struct EmptyEventView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyEventView()
    }
}

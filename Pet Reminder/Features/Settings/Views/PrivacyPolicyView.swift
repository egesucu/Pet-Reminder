//
//  PrivacyPolicyView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 17.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text(.privacyPolicyContent)
                    .padding(.all)
            }
        }
        .navigationTitle(Text(.privacyPolicyTitle))
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}

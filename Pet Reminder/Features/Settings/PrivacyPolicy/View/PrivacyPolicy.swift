//
//  PrivacyPolicy.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 17.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared

struct PrivacyPolicy: View {
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

#if DEBUG
#Preview {
    NavigationStack {
        PrivacyPolicy()
    }
}
#endif

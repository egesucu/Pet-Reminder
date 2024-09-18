//
//  PrivacyPolicyView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 17.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI


struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("privacy_policy_content")
                    .padding(.all)
            }
        }
        .navigationTitle(Text("privacy_policy_title"))

    }
}

#Preview {
    PrivacyPolicyView()
}

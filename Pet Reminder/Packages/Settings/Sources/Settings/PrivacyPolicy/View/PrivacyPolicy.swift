//
//  PrivacyPolicy.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 17.09.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//

import SwiftUI
import Shared
import SharedUI

struct PrivacyPolicy: View {
    var body: some View {
        ScrollView {
            VStack {
                Text(SharedStrings.privacyPolicyContent)
                    .padding(.all)
            }
        }
        .navigationTitle(Text(SharedStrings.privacyPolicyTitle))
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        PrivacyPolicy()
    }
}
#endif

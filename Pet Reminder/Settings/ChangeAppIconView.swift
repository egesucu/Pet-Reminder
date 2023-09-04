//
//  ChangeAppIconView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 2.09.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//

import SwiftUI

struct ChangeAppIconView: View {
    
    @State private var viewModel = AppIconManager()
    @State private var logoChanged = false
    
    var body: some View {
        VStack {
            ScrollView {
                ForEach(AppIcon.allCases) { icon in
                    ZStack {
                        Capsule()
                            .fill(Color.white)
                            .frame(height: 100)
                            .overlay {
                                Capsule()
                                    .stroke(viewModel.selectedAppIcon == icon ? Color.yellow : Color.clear, lineWidth: 2)
                            }
                            .onTapGesture {
                                withAnimation {
                                    logoChanged.toggle()
                                    viewModel.updateAppIcon(to: icon)
                                }
                            }
                            .sensoryFeedback(.success, trigger: logoChanged)
                        HStack {
                            Image(uiImage: icon.preview)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .padding(.trailing, 10)
                            Text(icon.description)
                                .font(.title)
                            Spacer()
                        }
                        .padding()
                        
                    }
                }
                .padding()
            }
        }
        .navigationTitle(Text("settings_change_icon"))
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        
    }
}

#Preview {
    ChangeAppIconView()
}

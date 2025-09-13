//
//  MapItemView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.08.2023.
//  Copyright © 2023 Ege Sucu. All rights reserved.
//
import SwiftUI
import MapKit
import Shared
import SFSafeSymbols

struct MapItemView: View {

    var location: Pin?
    @State private var showOpenMapAlert = false

    var body: some View {
        VStack {
            if let location {
                Text(location.name)
                    .bold()
                    .font(.title3)
                    .padding(.bottom, 10)
                HStack {
                    VStack(alignment: .leading) {
                        if let phoneNumber = location.phoneNumber {
                            HStack {
                                Image(systemSymbol: .phoneFill)
                                    .foregroundStyle(.accent)
                                Text(phoneNumber)
                                    .foregroundStyle(.accent)
                                    .onTapGesture {
                                        let url = URL(
                                            string: "tel:\(phoneNumber)"
                                        ) ?? URL(
                                            string: "https://www.google.com"
                                        )!
                                        UIApplication.shared.open(url)
                                    }
                                Spacer()
                            }
                            .tint(.accent)
                        }
                        if let fullAdress = location.fullAdress {
                            HStack {
                                Image(systemSymbol: .buildingFill)
                                    .foregroundStyle(.accent)
                                Text(fullAdress)
                                Spacer()
                            }

                        }
                    }
                }
                Button(action: openMapDetail) {
                    Text(.mapOpenIn)
                }
                .buttonStyle(.bordered)
                .padding(.trailing, 10)
            }
        }
        .alert("find_vet_open", isPresented: $showOpenMapAlert) {
            ForEach(MapApplication.allCases, id: \.self) { app in
                Button(app.name) {
                    if let location {
                        openURLWithMap(
                            location: location,
                            application: app
                        )
                    }
                }
            }
            Button(role: .cancel, action: {})
        }
    }

    func openMapDetail() {
        showOpenMapAlert.toggle()
    }
}

//
//  MapItemView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.08.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//
import SwiftUI
import MapKit

struct MapItemView: View {

    @AppStorage(Strings.tintColor) var tintColor = Color.accent

    var item: Pin
    var onSetRegion: (Pin) -> Void

    var body: some View {
        VStack {
            Text(item.name)
                .bold()
                .font(.title3)
                .padding(.bottom, 10)
            HStack {
                VStack(alignment: .leading) {
                    if let phoneNumber = item.phoneNumber {
                        HStack {
                            Image(systemName: "phone.fill")
                                .foregroundStyle(tintColor)
                            Text(phoneNumber)
                                .foregroundStyle(tintColor)
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
                        .tint(tintColor)
                    }
                    if let subThoroughfare = item.subThoroughfare,
                       let thoroughfare = item.thoroughfare,
                       let locality = item.locality,
                       let postalCode = item.postalCode {
                        HStack {
                            Image(systemName: "building.fill")
                                .foregroundStyle(tintColor)
                            Text("\(thoroughfare), \(subThoroughfare)")
                            Text("\n\(postalCode), \(locality)")
                            Spacer()
                        }

                    }
                }
                Spacer()
                Button(action: {
                    onSetRegion(item)
                }, label: {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                })
                .padding(.trailing, 10)
            }

        }
    }
}

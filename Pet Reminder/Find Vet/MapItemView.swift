//
//  MapItemView.swift
//  Pet Reminder
//
//  Created by Ege Sucu on 9.08.2023.
//  Copyright © 2023 Softhion. All rights reserved.
//
#if !targetEnvironment(simulator)
import SwiftUI
import MapKit

struct MapItemView: View {
    
    @AppStorage(Strings.tintColor) var tintColor = Color.systemGreen
    
    var item: Pin
    
    var onSetRegion: (MKMapItem) -> Void
    
    var body: some View {
        VStack {
            Text(item.item.name ?? "")
                .bold()
                .font(.title3)
                .padding(.bottom, 10)
            HStack {
                VStack(alignment: .leading) {
                    if let phoneNumber = item.item.phoneNumber {
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
                    if let subThoroughfare = item.item.placemark.subThoroughfare,
                       let thoroughfare = item.item.placemark.thoroughfare,
                       let locality = item.item.placemark.locality,
                       let postalCode = item.item.placemark.postalCode {
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
                    onSetRegion(item.item)
                }, label: {
                    Image(systemName: "mappin.circle.fill")
                        .font(.title)
                })
                .padding(.trailing, 10)
            }

        }
    }
}
#Preview {
    MapItemView(item: .init(item: .init())) { _ in
        
    }
}
#endif

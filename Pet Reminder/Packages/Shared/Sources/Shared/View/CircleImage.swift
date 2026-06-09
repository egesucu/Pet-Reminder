//
//  CircleImage.swift
//  Shared
//
//  Created by Sucu, Ege on 08.06.26.
//

import SwiftUI

public struct CircleImage: View {
    
    let avatarSize: CGFloat
    let imageData: Data?
    let kind: Kind
    
    public init(
        avatarSize: CGFloat = .avatar120,
        imageData: Data?,
        kind: Kind
    ) {
        self.avatarSize = avatarSize
        self.imageData = imageData
        self.kind = kind
    }
    
    public var body: some View {
        if let imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
                .imageStyle(width: avatarSize)
            
        } else {
            Image(.generateDefaultData(kind: kind))
                .imageStyle(width: avatarSize)
        }
    }
}

extension Image {
    func imageStyle(width: CGFloat) -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(width: width)
            .clipShape(.circle)
    }
}

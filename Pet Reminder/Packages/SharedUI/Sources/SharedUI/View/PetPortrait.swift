import Shared
import SwiftUI
import UIKit

/// A decorative pet image. The surrounding row or form supplies the pet’s identity.
public struct PetPortrait: View {
    public enum Style {
        case avatar(size: CGFloat)
        case photoPreview
        case photoPlaceholder(size: CGFloat)
        case circularPlaceholder(size: CGFloat)
    }

    private let imageData: Data?
    private let kind: Kind
    private let style: Style

    public init(imageData: Data?, kind: Kind, style: Style = .avatar(size: .avatar120)) {
        self.imageData = imageData
        self.kind = kind
        self.style = style
    }

    public var body: some View {
        portrait.accessibilityHidden(true)
    }

    @ContentBuilder private var portrait: some View {
        switch style {
        case .avatar(let size):
            image
                .resizable()
                .scaledToFit()
                .frame(width: size)
                .clipShape(.circle)
                .overlay { Circle().stroke(.white, lineWidth: 3) }
                .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        case .photoPreview:
            image
                .resizable()
                .scaledToFit()
                .clipShape(.rect(cornerRadius: .radius10))
                .glassEffect(.identity)
        case .photoPlaceholder(let size):
            image
                .resizable()
                .frame(width: size, height: size)
                .clipShape(.rect(cornerRadius: .radius10))
        case .circularPlaceholder(let size):
            image
                .resizable()
                .frame(width: size, height: size)
                .clipShape(.circle)
        }
    }

    private var image: Image {
        if let imageData, let photo = UIImage(data: imageData) {
            return Image(uiImage: photo)
        }
        return Image(.generateDefaultData(kind: kind))
    }
}

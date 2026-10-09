import Shared
import SwiftUI

public extension Kind {
    var image: Image {
        return switch self {
        case .cat:
            Image(.defaultCat)
                .resizable()
        case .dog:
            Image(.defaultDog)
                .resizable()
        case .fish:
            Image(.defaultFish)
                .resizable()
        case .bird:
            Image(.defaultBird)
                .resizable()
        case .other:
            Image(.defaultOther)
                .resizable()
        }
    }

    var uiImage: UIImage {
        return switch self {
        case .cat:
            UIImage(resource: .defaultCat)
        case .dog:
            UIImage(resource: .defaultDog)
        case .fish:
            UIImage(resource: .defaultFish)
        case .bird:
            UIImage(resource: .defaultBird)
        case .other:
            UIImage(resource: .defaultOther)
        }
    }
}

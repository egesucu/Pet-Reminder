import Foundation
import Shared
import UIKit

public extension Kind {
    /// Encodes the bundled portrait for sample data that needs a stored photo.
    func defaultPhotoData(jpegQuality: CGFloat) -> Data? {
        UIImage(resource: .generateDefaultData(kind: self)).jpegData(compressionQuality: jpegQuality)
    }
}

import Foundation
import ImageIO
import UniformTypeIdentifiers

public enum ImageDownsampling {
    /// Creates a display-sized image without decoding a full-resolution bitmap.
    /// Preserves orientation, aspect ratio and transparency; never enlarges the source.
    /// Returns nil when decoding or encoding fails instead of storing the original.
    public nonisolated static func downsampleIfNeeded(
        data: Data,
        maxDimension: CGFloat = 1024,
        jpegQuality: CGFloat = 0.8
    ) -> Data? {
        guard maxDimension.isFinite, maxDimension >= 1,
              let source = CGImageSourceCreateWithData(data as CFData, [kCGImageSourceShouldCache: false] as CFDictionary),
              let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let width = properties[kCGImagePropertyPixelWidth] as? NSNumber,
              let height = properties[kCGImagePropertyPixelHeight] as? NSNumber,
              width.doubleValue > 0, height.doubleValue > 0 else { return nil }

        let target = min(maxDimension, max(CGFloat(width.doubleValue), CGFloat(height.doubleValue)))
        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: Int(target)
        ]
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else { return nil }

        let hasAlpha: Bool
        switch image.alphaInfo {
        case .first, .last, .premultipliedFirst, .premultipliedLast, .alphaOnly: hasAlpha = true
        default: hasAlpha = false
        }
        let type = hasAlpha ? UTType.png : UTType.jpeg
        let output = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(output, type.identifier as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, image, [
            kCGImageDestinationLossyCompressionQuality: min(1, max(0, jpegQuality))
        ] as CFDictionary)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return output as Data
    }
}

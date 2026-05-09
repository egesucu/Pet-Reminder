//
//  ImageDownsampling.swift
//  Shared
//
//  Created by Assistant on 17.09.2025.
//

import Foundation
import UIKit
import ImageIO
import MobileCoreServices

public enum ImageDownsampling {

    /// Downsamples image data to a maximum pixel dimension and compresses to JPEG.
    /// - Parameters:
    ///   - data: Original image data.
    ///   - maxDimension: Maximum width/height in pixels for the downsampled image.
    ///   - jpegQuality: JPEG compression quality (0.0 - 1.0).
    /// - Returns: Processed image data if successful; otherwise the original data.
    public static func downsampleIfNeeded(
        data: Data,
        maxDimension: CGFloat = 1024,
        jpegQuality: CGFloat = 0.8
    ) -> Data? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return data
        }

        let options: [NSString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: Int(maxDimension)
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            return data
        }

        let image = UIImage(cgImage: cgImage)
        guard let jpeg = image.jpegData(compressionQuality: jpegQuality) else {
            return data
        }
        return jpeg
    }
}

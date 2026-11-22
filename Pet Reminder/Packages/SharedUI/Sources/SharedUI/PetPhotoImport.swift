import Foundation

/// Both import paths store an optimized copy suitable for large Retina previews.
public enum PetPhotoImport {
    public nonisolated static func normalized(_ data: Data) -> Data? {
        ImageDownsampling.downsampleIfNeeded(data: data, maxDimension: 2048, jpegQuality: 0.88)
    }

    public nonisolated static func prepare(_ data: Data) async -> Data? {
        await Task.detached(priority: .userInitiated) { normalized(data) }.value
    }
}

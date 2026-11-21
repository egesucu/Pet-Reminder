import Foundation
import UIKit
import ImageIO
import UniformTypeIdentifiers
import Testing
import Shared
import SharedUI
@testable import Pets
@testable import Events
@testable import Pet_Reminder

@MainActor
struct IPadBehaviorTests {
    @Test("Pet search matches words across name and breed without case or accents")
    func search() {
        #expect(PetSearch.matches(name: "Lúna Belle", breed: "Golden Retriever", query: " luna  GOLDEN "))
        #expect(PetSearch.matches(name: "Luna", breed: nil, query: " \n"))
        #expect(!PetSearch.matches(name: "Luna", breed: nil, query: "Beagle"))
        #expect(!PetSearch.matches(name: "Luna", breed: "Beagle", query: "Luna Collie"))
    }

    @Test("New windows stay distinct and preserve identity when the selected pet changes")
    func windowIdentity() throws {
        let id = UUID()
        var first = PetWindowState(petID: id)
        let second = PetWindowState(petID: id)
        #expect(first != second)
        let instance = first.instanceID
        first.petID = UUID()
        let restored = try JSONDecoder().decode(PetWindowState.self, from: JSONEncoder().encode(first))
        #expect(restored == first && restored.instanceID == instance)
    }

    @Test("App Intent routing targets one window and preserves independent navigation")
    func independentWindows() throws {
        let inbox = AppNavigationCoordinator()
        let first = AppNavigationCoordinator()
        let second = AppNavigationCoordinator()
        let id = UUID()
        inbox.openPet(id: id)
        inbox.connect(to: first)
        #expect(first.pendingRequest?.destination == .pet(id))
        #expect(inbox.pendingRequest == nil)
        first.selectedTab = .events
        second.selectedTab = .settings
        inbox.connect(to: second)
        inbox.open(.addPet)
        #expect(first.selectedTab == .events)
        #expect(first.pendingRequest?.destination == .pet(id))
        #expect(second.selectedTab == .home)
        #expect(second.pendingRequest?.destination == .addPet)
        let request = try #require(second.pendingRequest)
        second.consume(request)
        #expect(first.pendingRequest != nil && second.pendingRequest == nil)
    }

    @Test("Background windows cannot consume App Intent requests")
    func backgroundRouting() {
        let inbox = AppNavigationCoordinator()
        let first = AppNavigationCoordinator()
        let second = AppNavigationCoordinator()
        inbox.connect(to: first)
        inbox.connect(to: second)
        inbox.disconnect(from: first)
        inbox.open(.addPet)
        #expect(second.pendingRequest?.destination == .addPet)
        inbox.disconnect(from: second)
        let id = UUID()
        inbox.openPet(id: id)
        #expect(inbox.pendingRequest?.destination == .pet(id))
        inbox.connect(to: first)
        #expect(first.pendingRequest?.destination == .pet(id) && inbox.pendingRequest == nil)
    }

    @Test("Photo imports reject invalid data and prepare Retina-sized display copies")
    func photoImport() throws {
        #expect(PetPhotoImport.normalized(Data("not an image".utf8)) == nil)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let source = UIGraphicsImageRenderer(size: CGSize(width: 2400, height: 1200), format: format).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 2400, height: 1200))
        }
        for data in [try #require(source.pngData()), try #require(source.jpegData(compressionQuality: 0.9))] {
            let result = try #require(PetPhotoImport.normalized(data))
            let image = try #require(UIImage(data: result)?.cgImage)
            #expect(max(image.width, image.height) <= 2048)
            #expect(image.width == image.height * 2)
        }
    }

    @Test("Valid sources larger than 20 MB are optimized instead of rejected")
    func largePhotoImport() async throws {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let image = UIGraphicsImageRenderer(size: CGSize(width: 4000, height: 2000), format: format).image { context in
            UIColor.blue.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 4000, height: 2000))
        }
        let output = NSMutableData()
        let destination = try #require(CGImageDestinationCreateWithData(output, UTType.tiff.identifier as CFString, 1, nil))
        CGImageDestinationAddImage(destination, try #require(image.cgImage), [
            kCGImagePropertyTIFFDictionary: [kCGImagePropertyTIFFCompression: 1]
        ] as CFDictionary)
        #expect(CGImageDestinationFinalize(destination))
        let source = output as Data
        #expect(source.count > 20 * 1024 * 1024)
        let prepared = try #require(await PetPhotoImport.prepare(source))
        let decoded = try #require(UIImage(data: prepared)?.cgImage)
        #expect(decoded.width == 2048 && decoded.height == 1024)
        #expect(prepared.count < source.count)
        let resultSource = try #require(CGImageSourceCreateWithData(prepared as CFData, nil))
        #expect(CGImageSourceGetType(resultSource) as String? == UTType.jpeg.identifier)
    }

    @Test("Transparent photos retain PNG and small photos are not enlarged")
    func transparentPhotoImport() throws {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        let image = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 50), format: format).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 50, height: 50))
        }
        let imageData = try #require(image.pngData())
        let prepared = try #require(PetPhotoImport.normalized(imageData))
        let source = try #require(CGImageSourceCreateWithData(prepared as CFData, nil))
        #expect(CGImageSourceGetType(source) as String? == UTType.png.identifier)
        let decoded = try #require(UIImage(data: prepared)?.cgImage)
        #expect(decoded.width == 100 && decoded.height == 50)
        #expect([CGImageAlphaInfo.first, .last, .premultipliedFirst, .premultipliedLast].contains(decoded.alphaInfo))
    }

    @Test("Camera orientation is applied before encoding the display copy")
    func orientedPhotoImport() throws {
        let image = UIGraphicsImageRenderer(size: CGSize(width: 100, height: 50)).image { context in
            UIColor.red.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 100, height: 50))
        }
        let output = NSMutableData()
        let destination = try #require(CGImageDestinationCreateWithData(output, UTType.jpeg.identifier as CFString, 1, nil))
        let original = try #require(image.cgImage)
        CGImageDestinationAddImage(destination, original, [kCGImagePropertyOrientation: 6] as CFDictionary)
        #expect(CGImageDestinationFinalize(destination))
        let prepared = try #require(PetPhotoImport.normalized(output as Data))
        let decoded = try #require(UIImage(data: prepared))
        #expect(decoded.imageOrientation == .up)
        #expect(decoded.cgImage?.width == original.height && decoded.cgImage?.height == original.width)
    }

    @Test("Escape protection detects changes without marking untouched drafts dirty")
    func draftChanges() {
        let pet = AddPet.Model()
        #expect(!pet.hasChanges)
        pet.name = "Luna"
        #expect(pet.hasChanges)
        pet.name = ""
        #expect(!pet.hasChanges)
        pet.kind = .cat
        #expect(pet.hasChanges)
        let event = EventCreationState()
        #expect(!event.hasChanges)
        event.start.addTimeInterval(60)
        #expect(event.hasChanges)
    }

    @Test("Refreshing one window never adopts another window's calendar filter")
    func independentFilters() throws {
        let suite = "IPadBehaviorTests.\(UUID())"
        let preferences = try #require(UserDefaults(suiteName: suite))
        defer { preferences.removePersistentDomain(forName: suite) }
        let first = EventManager(preferences: preferences)
        let second = EventManager(preferences: preferences)
        let available = ["pets", "personal"]
        #expect(first.restoredCalendarID(available: available, petID: "pets") == "pets")
        first.selectedCalendar = .init(id: "pets", title: "Pets")
        #expect(second.restoredCalendarID(available: available, petID: "pets") == "pets")
        second.selectedCalendar = .init(id: "personal", title: "Personal")
        #expect(first.restoredCalendarID(available: available, petID: "pets") == "pets")
        #expect(second.restoredCalendarID(available: available, petID: "pets") == "personal")
        first.selectedCalendar = nil
        #expect(first.restoredCalendarID(available: available, petID: "pets") == nil)
        #expect(second.restoredCalendarID(available: ["pets"], petID: "pets") == "pets")
    }
}

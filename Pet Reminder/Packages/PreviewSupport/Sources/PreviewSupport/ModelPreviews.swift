import Foundation
import Shared
import SharedUI

public extension Pet {
    @MainActor static var preview: Pet { previews[0] }
    @MainActor static var previews: [Pet] {
        let date = Date(timeIntervalSince1970: 1_780_000_000)
        return [("Luna", Kind.dog, "Beagle"), ("Milo", .cat, "Maine Coon"), ("Coco", .bird, "Budgie")].map { name, kind, breed in
            let pet = Pet(birthday: date, name: name, createdAt: date, image: kind.uiImage.jpegData(compressionQuality: 0.8), breed: breed, kind: kind)
            for feed in Feed.previews { pet.addFeed(feed) }
            for vaccine in Vaccine.previews { pet.addVaccine(vaccine) }
            return pet
        }
    }
}
public extension Feed {
    @MainActor static var preview: Feed { previews[0] }
    @MainActor static var previews: [Feed] {
        (0..<5).map { offset in
            let day = Date(timeIntervalSince1970: 1_780_000_000 - Double(offset) * 86400)
            return Feed(eveningFed: true, eveningFedStamp: day.addingTimeInterval(64800), feedDate: day, morningFed: true, morningFedStamp: day.addingTimeInterval(28800))
        }
    }
}
public extension Vaccine {
    @MainActor static var preview: Vaccine { previews[0] }
    @MainActor static var previews: [Vaccine] {
        Strings.demoVaccines.map { Vaccine(date: Date(timeIntervalSince1970: 1_780_000_000), name: $0) }
    }
}

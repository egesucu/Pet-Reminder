import Testing
@testable import Pet_Reminder

@Suite("Shared Model Tests") struct SharedModelsTests {
    @Test func testLanguageWithParameters() async throws {
        let name = "Viski"
        let notExpectedOutput = "notification_content-\(name)"
        let stringKey: String.LocalizationValue = "notification_content \(name)"
        let localization = String(localized: stringKey, bundle: .main)
        #expect(localization != notExpectedOutput)
    }
}

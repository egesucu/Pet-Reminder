/// Tests validating shared model and localization behavior.

import Testing
@testable import Pet_Reminder

/// Suite covering tests related to shared models and localization functionality.
@Suite("Shared Model Tests") struct SharedModelsTests {
    
    /// Tests the localization string interpolation with parameters.
    ///
    /// - Scenario: Create a localized string using a parameter and verify
    ///   that the resulting localization does not incorrectly include
    ///   literal parameter syntax.
    /// - Parameters:
    ///   - name: A string used as a parameter in the localization key.
    /// - Expected behavior: The localized string should not match the literal
    ///   concatenation form and should correctly resolve localization keys with parameters.
    /// - Assertion: Ensures that the localization result is not equal to an incorrect literal string.
    @Test func testLanguageWithParameters() async throws {
        let name = "Viski"
        let notExpectedOutput = "notification_content-\(name)"
        let stringKey: String.LocalizationValue = "notification_content \(name)"
        let localization = String(localized: stringKey, bundle: .main)
        #expect(localization != notExpectedOutput)
    }
}


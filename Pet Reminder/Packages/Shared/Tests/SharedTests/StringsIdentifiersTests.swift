
@Suite("Strings identifier tests")
struct StringsIdentifiersTests {

    @Test
    func notificationIdentifierFormat() {
        let id = Strings.notificationIdentifier("Buddy", "morning")
        #expect(id == "Buddy-morning-notification")
        #expect(id.contains("Buddy"))
        #expect(id.contains("morning"))
    }
}

import Testing
@testable import PasteboardKit

@Suite("Pasteboard Reader Tests")
struct PasteboardKitTests {
    
    @Test("Pasteboard reader initialization")
    func pasteboardReaderInitialization() {
        let reader = PasteboardReader()
        // Just verify it initializes without crashing
        #expect(reader != nil)
    }
    
    // Note: Testing actual clipboard content is tricky in automated tests
    // since it depends on system state. In practice, you'd want to test
    // with mock NSPasteboard instances.
}


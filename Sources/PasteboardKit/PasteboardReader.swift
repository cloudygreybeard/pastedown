import Foundation
import AppKit

/// Represents the content available in the macOS pasteboard
public struct PasteboardContent {
    /// All available UTI types in the pasteboard
    public let availableTypes: [String]
    
    /// HTML content, if available
    public let html: String?
    
    /// RTF content, if available
    public let rtf: Data?
    
    /// Plain text content, if available
    public let plainText: String?
    
    /// Attributed string, if available
    public let attributedString: NSAttributedString?
    
    public init(
        availableTypes: [String],
        html: String?,
        rtf: Data?,
        plainText: String?,
        attributedString: NSAttributedString?
    ) {
        self.availableTypes = availableTypes
        self.html = html
        self.rtf = rtf
        self.plainText = plainText
        self.attributedString = attributedString
    }
}

/// Reader for macOS NSPasteboard with support for multiple formats
public class PasteboardReader {
    private let pasteboard: NSPasteboard
    
    /// Initialize with a specific pasteboard
    /// - Parameter pasteboard: The pasteboard to read from (defaults to general pasteboard)
    public init(pasteboard: NSPasteboard = .general) {
        self.pasteboard = pasteboard
    }
    
    /// Read all available content from the pasteboard
    /// - Returns: PasteboardContent with all available formats
    public func read() -> PasteboardContent {
        let types = pasteboard.types?.map { $0.rawValue } ?? []
        
        return PasteboardContent(
            availableTypes: types,
            html: readHTML(),
            rtf: readRTF(),
            plainText: readPlainText(),
            attributedString: readAttributedString()
        )
    }
    
    /// Read HTML content from the pasteboard
    /// - Returns: HTML string if available
    public func readHTML() -> String? {
        // Try public.html type first
        if let data = pasteboard.data(forType: .html) {
            // Try UTF-8 first
            if let html = String(data: data, encoding: .utf8) {
                return html
            }
            // Fall back to UTF-16
            if let html = String(data: data, encoding: .utf16) {
                return html
            }
        }
        
        // Some apps might use legacy type
        if let types = pasteboard.types,
           types.contains(NSPasteboard.PasteboardType("public.html")) {
            if let data = pasteboard.data(forType: NSPasteboard.PasteboardType("public.html")) {
                return String(data: data, encoding: .utf8)
            }
        }
        
        return nil
    }
    
    /// Read RTF content from the pasteboard
    /// - Returns: RTF data if available
    public func readRTF() -> Data? {
        return pasteboard.data(forType: .rtf)
    }
    
    /// Read plain text from the pasteboard
    /// - Returns: Plain text string if available
    public func readPlainText() -> String? {
        return pasteboard.string(forType: .string)
    }
    
    /// Read attributed string from the pasteboard
    /// - Returns: NSAttributedString if available
    public func readAttributedString() -> NSAttributedString? {
        // Try to read RTF and convert to attributed string
        if let rtfData = readRTF() {
            return NSAttributedString(rtf: rtfData, documentAttributes: nil)
        }
        
        // Try to read RTFD
        if let rtfdData = pasteboard.data(forType: .rtfd) {
            return NSAttributedString(rtfd: rtfdData, documentAttributes: nil)
        }
        
        return nil
    }
    
    /// Check if the pasteboard contains a specific type
    /// - Parameter type: The UTI type to check for
    /// - Returns: true if the type is available
    public func contains(type: NSPasteboard.PasteboardType) -> Bool {
        return pasteboard.types?.contains(type) ?? false
    }
    
    /// Get all available types as a formatted string for debugging
    /// - Returns: Multi-line string with all available types
    public func debugTypes() -> String {
        guard let types = pasteboard.types else {
            return "No types available"
        }
        
        var result = "Available Pasteboard Types:\n"
        for (index, type) in types.enumerated() {
            result += "  \(index + 1). \(type.rawValue)\n"
            
            // Show data size if available
            if let data = pasteboard.data(forType: type) {
                result += "     Size: \(data.count) bytes\n"
            }
        }
        
        return result
    }
}



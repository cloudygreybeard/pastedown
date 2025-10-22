import Foundation
import PasteboardKit
import MarkdownGenerator

// MARK: - CLI Application

struct CLI {
    enum Command {
        case convert
        case inspect
        case help
        case version
    }
    
    static func run() {
        let args = CommandLine.arguments.dropFirst() // Drop program name
        
        let command = parseCommand(from: Array(args))
        
        switch command {
        case .convert:
            runConvert()
        case .inspect:
            runInspect()
        case .help:
            printHelp()
        case .version:
            printVersion()
        }
    }
    
    private static func parseCommand(from args: [String]) -> Command {
        guard let firstArg = args.first else {
            return .convert // Default action
        }
        
        switch firstArg {
        case "inspect", "-i", "--inspect":
            return .inspect
        case "help", "-h", "--help":
            return .help
        case "version", "-v", "--version":
            return .version
        default:
            return .convert
        }
    }
    
    private static func runConvert() {
        let reader = PasteboardReader()
        let content = reader.read()
        
        // Parse conversion options
        let args = Array(CommandLine.arguments.dropFirst())
        let options = parseConvertOptions(from: args)
        
        let result = convertContent(content, options: options)
        
        switch result {
        case .success(let markdown):
            print(markdown, terminator: "")
        case .failure(let error):
            fprintln("Error: \(error)", to: .stderr)
            exit(1)
        }
    }
    
    private static func parseConvertOptions(from args: [String]) -> ConvertOptions {
        var options = ConvertOptions()
        
        for (index, arg) in args.enumerated() {
            switch arg {
            case "--from":
                if index + 1 < args.count {
                    options.sourceType = args[index + 1]
                }
            case "--priority":
                if index + 1 < args.count {
                    options.priority = args[index + 1].split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                }
            case "--merge":
                if index + 1 < args.count {
                    options.mergeTypes = args[index + 1].split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                }
            case "--separator":
                if index + 1 < args.count {
                    options.separator = args[index + 1]
                }
            case "--all":
                options.showAll = true
            default:
                break
            }
        }
        
        return options
    }
    
    struct ConvertOptions {
        var sourceType: String? = nil
        var priority: [String] = ["html", "text"]
        var mergeTypes: [String]? = nil
        var separator: String = "\n\n"
        var showAll: Bool = false
    }
    
    enum ConvertResult {
        case success(String)
        case failure(String)
    }
    
    private static func convertContent(_ content: PasteboardContent, options: ConvertOptions) -> ConvertResult {
        // If --all, show all conversions
        if options.showAll {
            return showAllConversions(content)
        }
        
        // If specific source type requested
        if let sourceType = options.sourceType {
            return convertFromSpecificType(content, type: sourceType)
        }
        
        // If merge requested
        if let mergeTypes = options.mergeTypes {
            return mergeContent(content, types: mergeTypes, separator: options.separator)
        }
        
        // Default priority-based conversion
        return convertWithPriority(content, priority: options.priority)
    }
    
    private static func convertFromSpecificType(_ content: PasteboardContent, type: String) -> ConvertResult {
        switch type.lowercased() {
        case "html":
            if let html = content.html {
                return convertHTML(html)
            }
            return .failure("HTML content not available")
        case "rtf":
            if let rtf = content.rtf {
                return convertRTF(rtf)
            }
            return .failure("RTF content not available")
        case "text":
            if let text = content.plainText {
                return .success(text)
            }
            return .failure("Plain text not available")
        case "attributed":
            if let attrString = content.attributedString {
                return .success(attrString.string)
            }
            return .failure("Attributed string not available")
        default:
            return .failure("Unknown source type: \(type)")
        }
    }
    
    private static func convertWithPriority(_ content: PasteboardContent, priority: [String]) -> ConvertResult {
        for type in priority {
            switch type.lowercased() {
            case "html":
                if let html = content.html {
                    let result = convertHTML(html)
                    if case .success = result { return result }
                }
            case "rtf":
                if let rtf = content.rtf {
                    let result = convertRTF(rtf)
                    if case .success = result { return result }
                }
            case "text":
                if let text = content.plainText {
                    return .success(text)
                }
            case "attributed":
                if let attrString = content.attributedString {
                    return .success(attrString.string)
                }
            default:
                continue
            }
        }
        
        return .failure("No convertible content found")
    }
    
    private static func mergeContent(_ content: PasteboardContent, types: [String], separator: String) -> ConvertResult {
        var results: [String] = []
        
        for type in types {
            switch type.lowercased() {
            case "html":
                if let html = content.html {
                    let result = convertHTML(html)
                    if case .success(let markdown) = result {
                        results.append(markdown)
                    }
                }
            case "rtf":
                if let rtf = content.rtf {
                    let result = convertRTF(rtf)
                    if case .success(let markdown) = result {
                        results.append(markdown)
                    }
                }
            case "text":
                if let text = content.plainText {
                    results.append(text)
                }
            case "attributed":
                if let attrString = content.attributedString {
                    results.append(attrString.string)
                }
            default:
                continue
            }
        }
        
        if results.isEmpty {
            return .failure("No content found for merging")
        }
        
        return .success(results.joined(separator: separator))
    }
    
    private static func showAllConversions(_ content: PasteboardContent) -> ConvertResult {
        var outputs: [String] = []
        
        if let html = content.html {
            let result = convertHTML(html)
            if case .success(let markdown) = result {
                outputs.append("=== HTML CONVERSION ===")
                outputs.append(markdown)
                outputs.append("")
            }
        }
        
        if let rtf = content.rtf {
            let result = convertRTF(rtf)
            if case .success(let markdown) = result {
                outputs.append("=== RTF CONVERSION ===")
                outputs.append(markdown)
                outputs.append("")
            }
        }
        
        if let text = content.plainText {
            outputs.append("=== PLAIN TEXT ===")
            outputs.append(text)
            outputs.append("")
        }
        
        if let attrString = content.attributedString {
            outputs.append("=== ATTRIBUTED STRING ===")
            outputs.append(attrString.string)
            outputs.append("")
        }
        
        if outputs.isEmpty {
            return .failure("No content available for conversion")
        }
        
        return .success(outputs.joined(separator: "\n"))
    }
    
    private static func convertHTML(_ html: String) -> ConvertResult {
        do {
            let converter = HTMLToMarkdownConverter()
            let markdown = try converter.convert(html)
            return .success(markdown)
        } catch {
            return .failure("HTML conversion failed: \(error)")
        }
    }
    
    private static func convertRTF(_ rtf: Data) -> ConvertResult {
        // For now, just return the RTF as plain text
        // TODO: Implement proper RTF to Markdown conversion
        if let rtfString = String(data: rtf, encoding: .utf8) {
            return .success(rtfString)
        }
        return .failure("RTF conversion failed")
    }
    
    private static func runInspect() {
        let reader = PasteboardReader()
        let content = reader.read()
        
        // Parse output format
        let args = Array(CommandLine.arguments.dropFirst())
        let outputFormat = parseOutputFormat(from: args)
        
        if outputFormat == .json {
            printJSON(content)
        } else {
            printText(content)
        }
    }
    
    private static func parseOutputFormat(from args: [String]) -> OutputFormat {
        for arg in args {
            if arg == "--output" {
                if let nextIndex = args.firstIndex(of: arg), nextIndex + 1 < args.count {
                    let format = args[nextIndex + 1]
                    if format == "json" { return .json }
                    if format == "plain" { return .plain }
                }
            }
            if arg == "--json" || arg == "-j" { return .json }
        }
        return .plain
    }
    
    enum OutputFormat {
        case plain
        case json
    }
    
    private static func printText(_ content: PasteboardContent) {
        print("SOURCE")
        print("Available types: \(content.availableTypes.count)")
        for type in content.availableTypes {
            print("  \(type)")
        }
        print()
        
        // HTML
        if let html = content.html {
            print("HTML (\(html.count) bytes):")
            print(truncateContent(html, maxLength: 200))
            print()
        }
        
        // RTF
        if let rtf = content.rtf {
            print("RTF (\(rtf.count) bytes):")
            if let rtfString = String(data: rtf, encoding: .utf8) {
                print(truncateContent(rtfString, maxLength: 200))
            } else {
                print("  (binary data)")
            }
            print()
        }
        
        // Plain Text
        if let text = content.plainText {
            print("Text (\(text.count) chars):")
            print(truncateContent(text, maxLength: 200))
            print()
        }
        
        // Attributed String
        if let attrString = content.attributedString {
            print("AttributedString (\(attrString.length) chars):")
            print(truncateContent(attrString.string, maxLength: 200))
            print()
        }
        
        // TARGET - Markdown conversion
        print("TARGET")
        if let html = content.html {
            do {
                let converter = HTMLToMarkdownConverter()
                let markdown = try converter.convert(html)
                print("Markdown (\(markdown.count) chars):")
                print(truncateContent(markdown, maxLength: 200))
            } catch {
                print("Markdown conversion failed: \(error)")
            }
        } else if let text = content.plainText {
            print("Markdown (plain text, \(text.count) chars):")
            print(truncateContent(text, maxLength: 200))
        } else {
            print("Markdown: (no convertible content)")
        }
    }
    
    private static func printJSON(_ content: PasteboardContent) {
        var json: [String: Any] = [:]
        
        // SOURCE section
        var source: [String: Any] = [:]
        source["types"] = content.availableTypes
        
        if let html = content.html {
            source["html"] = [
                "size": html.count,
                "content": html
            ]
        }
        
        if let rtf = content.rtf {
            source["rtf"] = [
                "size": rtf.count,
                "content": String(data: rtf, encoding: .utf8) ?? ""
            ]
        }
        
        if let text = content.plainText {
            source["text"] = [
                "size": text.count,
                "content": text
            ]
        }
        
        if let attrString = content.attributedString {
            source["attributedString"] = [
                "length": attrString.length,
                "string": attrString.string
            ]
        }
        
        json["source"] = source
        
        // TARGET section - Markdown conversion
        var target: [String: Any] = [:]
        
        if let html = content.html {
            do {
                let converter = HTMLToMarkdownConverter()
                let markdown = try converter.convert(html)
                target["markdown"] = [
                    "size": markdown.count,
                    "content": markdown,
                    "source": "html"
                ]
            } catch {
                target["markdown"] = [
                    "error": "Conversion failed: \(error)",
                    "source": "html"
                ]
            }
        } else if let text = content.plainText {
            target["markdown"] = [
                "size": text.count,
                "content": text,
                "source": "plain_text"
            ]
        } else {
            target["markdown"] = [
                "error": "No convertible content",
                "source": "none"
            ]
        }
        
        json["target"] = target
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print(jsonString)
            }
        } catch {
            print("Error: Failed to serialize JSON")
        }
    }
    
    private static func truncateContent(_ content: String, maxLength: Int) -> String {
        if content.count <= maxLength {
            return content
        }
        let truncated = String(content.prefix(maxLength))
        return "\(truncated)... (\(content.count - maxLength) more chars)"
    }
    
    private static func printHelp() {
        print("""
        pastedown - macOS Pasteboard to Markdown
        
        USAGE:
            pastedown [COMMAND]
        
        COMMANDS:
            (none)       Convert pasteboard to Markdown and print to stdout
            inspect      Inspect pasteboard contents and show all available formats
            help         Show this help message
            version      Show version information
        
        OPTIONS:
            --output json|plain   Output format for inspect command (default: plain)
            --json, -j            Shortcut for --output json
            
            # Source selection
            --from TYPE           Force specific source type (html, rtf, text, attributed)
            --priority TYPES      Set priority order (e.g., "html,rtf,text")
            --merge TYPES         Merge multiple types (e.g., "html,text")
            --separator STRING    Separator for merged content (default: "\\n\\n")
            --all                 Show all available conversions
        
        EXAMPLES:
            # Convert pasteboard to Markdown (default priority)
            pastedown
            
            # Force HTML conversion
            pastedown --from html
            
            # Set custom priority
            pastedown --priority rtf,html,text
            
            # Merge HTML and text
            pastedown --merge html,text
            
            # Merge with custom separator
            pastedown --merge html,text --separator "\\n---\\n"
            
            # Show all conversions
            pastedown --all
            
            # Inspect pasteboard
            pastedown inspect
            
            # Inspect in JSON format
            pastedown inspect --output json
        
        The tool reads formatted text from the pasteboard (HTML, RTF, etc.)
        and converts it to clean Markdown format, preserving:
          - Text formatting (bold, italic)
          - Headings
          - Links
          - Lists (ordered and unordered)
          - Code blocks
          - Tables
          - Blockquotes
        """)
    }
    
    private static func printVersion() {
        let version = getVersion()
        print("pastedown version \(version)")
    }
    
    private static func getVersion() -> String {
        // Try to get version from git
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
        process.arguments = ["describe", "--tags", "--always", "--dirty"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe
        
        do {
            try process.run()
            process.waitUntilExit()
            
            if process.terminationStatus == 0 {
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                if let version = String(data: data, encoding: .utf8) {
                    return version.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
        } catch {
            // Fall through to default version
        }
        
        // Fallback to default version
        return "0.1.0"
    }
}

// MARK: - Utility Functions

func fprintln(_ message: String, to output: OutputType) {
    switch output {
    case .stderr:
        FileHandle.standardError.write((message + "\n").data(using: .utf8)!)
    case .stdout:
        print(message)
    }
}

enum OutputType {
    case stdout
    case stderr
}

// MARK: - Entry Point

CLI.run()



import Foundation

/// Converts HTML to Markdown format
public class HTMLToMarkdownConverter {
    
    public init() {}
    
    /// Convert HTML string to Markdown
    /// - Parameter html: HTML string to convert
    /// - Returns: Markdown formatted string
    public func convert(_ html: String) throws -> String {
        let data = Data(html.utf8)
        let document = try XMLDocument(data: data, options: [.documentTidyHTML])
        
        guard let root = document.rootElement() else {
            throw ConversionError.noRootElement
        }
        
        // Find the body element, or use root if no body
        let bodyElement = root.elements(forName: "body").first ?? root
        
        var context = ConversionContext()
        let markdown = convertElement(bodyElement, context: &context)
        
        // Clean up the markdown
        return cleanupMarkdown(markdown)
    }
    
    private func convertElement(_ element: XMLElement, context: inout ConversionContext) -> String {
        let tagName = element.name?.lowercased() ?? ""
        
        switch tagName {
        case "p":
            return convertParagraph(element, context: &context)
        case "br":
            return "\n"
        case "strong", "b":
            return "**\(convertChildren(element, context: &context))**"
        case "em", "i":
            return "*\(convertChildren(element, context: &context))*"
        case "code":
            return "`\(element.stringValue ?? "")`"
        case "pre":
            return convertPreformatted(element, context: &context)
        case "a":
            return convertLink(element, context: &context)
        case "h1", "h2", "h3", "h4", "h5", "h6":
            return convertHeading(element, context: &context)
        case "ul":
            return convertUnorderedList(element, context: &context)
        case "ol":
            return convertOrderedList(element, context: &context)
        case "li":
            return convertChildren(element, context: &context)
        case "blockquote":
            return convertBlockquote(element, context: &context)
        case "hr":
            return "\n---\n"
        case "img":
            return convertImage(element)
        case "table":
            return convertTable(element, context: &context)
        case "div", "span", "body", "html":
            // Container elements - just process children
            return convertChildren(element, context: &context)
        default:
            // Unknown elements - just process children
            return convertChildren(element, context: &context)
        }
    }
    
    private func convertChildren(_ element: XMLElement, context: inout ConversionContext) -> String {
        var result = ""
        
        for child in element.children ?? [] {
            if let childElement = child as? XMLElement {
                result += convertElement(childElement, context: &context)
            } else if child.kind == .text {
                result += child.stringValue ?? ""
            }
        }
        
        return result
    }
    
    private func convertParagraph(_ element: XMLElement, context: inout ConversionContext) -> String {
        let content = convertChildren(element, context: &context).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return "" }
        return "\(content)\n\n"
    }
    
    private func convertHeading(_ element: XMLElement, context: inout ConversionContext) -> String {
        let level = Int(element.name?.last?.description ?? "1") ?? 1
        let content = convertChildren(element, context: &context).trimmingCharacters(in: .whitespacesAndNewlines)
        let prefix = String(repeating: "#", count: level)
        return "\(prefix) \(content)\n\n"
    }
    
    private func convertLink(_ element: XMLElement, context: inout ConversionContext) -> String {
        let text = convertChildren(element, context: &context)
        let href = element.attribute(forName: "href")?.stringValue ?? ""
        
        // If text and href are the same, just use the URL
        if text == href {
            return href
        }
        
        return "[\(text)](\(href))"
    }
    
    private func convertImage(_ element: XMLElement) -> String {
        let alt = element.attribute(forName: "alt")?.stringValue ?? ""
        let src = element.attribute(forName: "src")?.stringValue ?? ""
        return "![\(alt)](\(src))"
    }
    
    private func convertUnorderedList(_ element: XMLElement, context: inout ConversionContext) -> String {
        context.listLevel += 1
        context.inList = true
        defer {
            context.listLevel -= 1
            context.inList = context.listLevel > 0
        }
        
        var result = ""
        let indent = String(repeating: "  ", count: context.listLevel - 1)
        
        for li in element.elements(forName: "li") {
            let content = convertChildren(li, context: &context).trimmingCharacters(in: .whitespacesAndNewlines)
            result += "\(indent)- \(content)\n"
        }
        
        if context.listLevel == 1 {
            result += "\n"
        }
        
        return result
    }
    
    private func convertOrderedList(_ element: XMLElement, context: inout ConversionContext) -> String {
        context.listLevel += 1
        context.inList = true
        defer {
            context.listLevel -= 1
            context.inList = context.listLevel > 0
        }
        
        var result = ""
        let indent = String(repeating: "  ", count: context.listLevel - 1)
        
        for (index, li) in element.elements(forName: "li").enumerated() {
            let content = convertChildren(li, context: &context).trimmingCharacters(in: .whitespacesAndNewlines)
            result += "\(indent)\(index + 1). \(content)\n"
        }
        
        if context.listLevel == 1 {
            result += "\n"
        }
        
        return result
    }
    
    private func convertBlockquote(_ element: XMLElement, context: inout ConversionContext) -> String {
        let content = convertChildren(element, context: &context)
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false)
        return lines.map { "> \($0)" }.joined(separator: "\n") + "\n\n"
    }
    
    private func convertPreformatted(_ element: XMLElement, context: inout ConversionContext) -> String {
        // Check if it contains a code element
        if let codeElement = element.elements(forName: "code").first {
            let code = codeElement.stringValue ?? ""
            let language = codeElement.attribute(forName: "class")?.stringValue?.replacingOccurrences(of: "language-", with: "") ?? ""
            return "```\(language)\n\(code)\n```\n\n"
        }
        
        let content = element.stringValue ?? ""
        return "```\n\(content)\n```\n\n"
    }
    
    private func convertTable(_ element: XMLElement, context: inout ConversionContext) -> String {
        var result = ""
        
        // Process thead
        if let thead = element.elements(forName: "thead").first {
            let headers = thead.elements(forName: "tr").first?.elements(forName: "th") ?? []
            if !headers.isEmpty {
                result += "| " + headers.map { convertChildren($0, context: &context).trimmingCharacters(in: .whitespacesAndNewlines) }.joined(separator: " | ") + " |\n"
                result += "| " + String(repeating: "--- | ", count: headers.count).dropLast(2) + "\n"
            }
        }
        
        // Process tbody
        let tbody = element.elements(forName: "tbody").first ?? element
        for tr in tbody.elements(forName: "tr") {
            let cells = tr.elements(forName: "td")
            if !cells.isEmpty {
                result += "| " + cells.map { convertChildren($0, context: &context).trimmingCharacters(in: .whitespacesAndNewlines) }.joined(separator: " | ") + " |\n"
            }
        }
        
        return result + "\n"
    }
    
    private func cleanupMarkdown(_ markdown: String) -> String {
        var result = markdown
        
        // Remove excessive blank lines (more than 2 consecutive newlines)
        while result.contains("\n\n\n") {
            result = result.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        }
        
        // Trim leading and trailing whitespace
        result = result.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Ensure file ends with a single newline
        result += "\n"
        
        return result
    }
}

// MARK: - Supporting Types

struct ConversionContext {
    var listLevel: Int = 0
    var inList: Bool = false
}

public enum ConversionError: Error {
    case noRootElement
    case invalidHTML
}


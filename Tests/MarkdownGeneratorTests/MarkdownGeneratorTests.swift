import Testing
@testable import MarkdownGenerator

@Suite("HTML to Markdown Conversion Tests")
struct MarkdownGeneratorTests {
    
    let converter = HTMLToMarkdownConverter()
    
    @Test("Convert simple paragraph")
    func simpleParagraph() throws {
        let html = "<p>Hello, world!</p>"
        let markdown = try converter.convert(html)
        #expect(markdown.trimmingCharacters(in: .whitespacesAndNewlines) == "Hello, world!")
    }
    
    @Test("Convert bold text")
    func boldText() throws {
        let html = "<p>This is <strong>bold</strong> text</p>"
        let markdown = try converter.convert(html)
        #expect(markdown.contains("**bold**"))
    }
    
    @Test("Convert italic text")
    func italicText() throws {
        let html = "<p>This is <em>italic</em> text</p>"
        let markdown = try converter.convert(html)
        #expect(markdown.contains("*italic*"))
    }
    
    @Test("Convert link")
    func link() throws {
        let html = #"<p><a href="https://example.com">Example</a></p>"#
        let markdown = try converter.convert(html)
        #expect(markdown.contains("[Example](https://example.com)"))
    }
    
    @Test("Convert headings")
    func headings() throws {
        let html = "<h1>Heading 1</h1><h2>Heading 2</h2><h3>Heading 3</h3>"
        let markdown = try converter.convert(html)
        #expect(markdown.contains("# Heading 1"))
        #expect(markdown.contains("## Heading 2"))
        #expect(markdown.contains("### Heading 3"))
    }
    
    @Test("Convert unordered list")
    func unorderedList() throws {
        let html = "<ul><li>Item 1</li><li>Item 2</li><li>Item 3</li></ul>"
        let markdown = try converter.convert(html)
        #expect(markdown.contains("- Item 1"))
        #expect(markdown.contains("- Item 2"))
        #expect(markdown.contains("- Item 3"))
    }
    
    @Test("Convert ordered list")
    func orderedList() throws {
        let html = "<ol><li>First</li><li>Second</li><li>Third</li></ol>"
        let markdown = try converter.convert(html)
        #expect(markdown.contains("1. First"))
        #expect(markdown.contains("2. Second"))
        #expect(markdown.contains("3. Third"))
    }
    
    @Test("Convert inline code")
    func codeInline() throws {
        let html = "<p>Use the <code>print()</code> function</p>"
        let markdown = try converter.convert(html)
        #expect(markdown.contains("`print()`"))
    }
    
    @Test("Convert code block")
    func codeBlock() throws {
        let html = "<pre><code>def hello():\n    print('Hello')</code></pre>"
        let markdown = try converter.convert(html)
        #expect(markdown.contains("```"))
        #expect(markdown.contains("def hello()"))
    }
    
    @Test("Convert blockquote")
    func blockquote() throws {
        let html = "<blockquote><p>This is a quote</p></blockquote>"
        let markdown = try converter.convert(html)
        #expect(markdown.contains("> This is a quote"))
    }
    
    @Test("Convert complex document")
    func complexDocument() throws {
        let html = """
        <html>
        <body>
        <h1>Main Title</h1>
        <p>This is a paragraph with <strong>bold</strong> and <em>italic</em> text.</p>
        <ul>
        <li>List item 1</li>
        <li>List item 2</li>
        </ul>
        <p>Check out <a href="https://example.com">this link</a>.</p>
        </body>
        </html>
        """
        
        let markdown = try converter.convert(html)
        #expect(markdown.contains("# Main Title"))
        #expect(markdown.contains("**bold**"))
        #expect(markdown.contains("*italic*"))
        #expect(markdown.contains("- List item 1"))
        #expect(markdown.contains("[this link](https://example.com)"))
    }
}


// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "pastedown",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "pastedown",
            targets: ["Pastedown"]
        ),
        .library(
            name: "PasteboardKit",
            targets: ["PasteboardKit"]
        )
    ],
    targets: [
        // Main CLI executable
        .executableTarget(
            name: "Pastedown",
            dependencies: ["PasteboardKit", "MarkdownGenerator"],
            path: "Sources/Pastedown"
        ),
        
        // Reusable library for reading macOS pasteboard
        .target(
            name: "PasteboardKit",
            dependencies: [],
            path: "Sources/PasteboardKit"
        ),
        
        // HTML to Markdown conversion
        .target(
            name: "MarkdownGenerator",
            dependencies: [],
            path: "Sources/MarkdownGenerator"
        )
    ]
)


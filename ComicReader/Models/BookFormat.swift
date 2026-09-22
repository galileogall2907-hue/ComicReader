import SwiftUI
import UniformTypeIdentifiers

enum BookFormat: String, CaseIterable, Identifiable, Codable, Hashable {
    case cbz
    case cbr
    case pdf
    case epub

    var id: String { rawValue }

    var displayName: String {
        rawValue.uppercased()
    }

    var fileExtension: String { rawValue }

    var symbolName: String {
        switch self {
        case .cbz, .cbr: "rectangle.stack"
        case .pdf: "doc.richtext"
        case .epub: "book"
        }
    }

    var tint: Color {
        switch self {
        case .cbz: Color(red: 0.86, green: 0.29, blue: 0.22)
        case .cbr: Color(red: 0.18, green: 0.47, blue: 0.78)
        case .pdf: Color(red: 0.72, green: 0.18, blue: 0.22)
        case .epub: Color(red: 0.20, green: 0.55, blue: 0.42)
        }
    }

    static func from(url: URL) -> BookFormat? {
        let ext = url.pathExtension.lowercased()
        return BookFormat.allCases.first { $0.fileExtension == ext }
    }
}
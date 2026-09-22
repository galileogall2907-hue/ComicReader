import Foundation

struct LibraryItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var format: BookFormat
    var author: String?
    var progress: Double
    var lastOpened: Date?
    let createdAt: Date
    var fileURL: URL

    init(
        id: UUID = UUID(),
        title: String,
        format: BookFormat,
        author: String? = nil,
        progress: Double = 0,
        lastOpened: Date? = nil,
        createdAt: Date = Date(),
        fileURL: URL
    ) {
        self.id = id
        self.title = title
        self.format = format
        self.author = author
        self.progress = progress
        self.lastOpened = lastOpened
        self.createdAt = createdAt
        self.fileURL = fileURL
    }
}

extension LibraryItem {
    static let samples: [LibraryItem] = [
        LibraryItem(title: "Noche en el muelle", format: .cbz, author: "Ana Ruiz", progress: 0.42, fileURL: URL(string: "file:///sample/noche.cbz")!),
        LibraryItem(title: "Circuitos", format: .cbr, author: "Leo Park", progress: 0.08, fileURL: URL(string: "file:///sample/circuitos.cbr")!),
        LibraryItem(title: "Tipografía viva", format: .pdf, author: "Estudio Norte", progress: 0.71, fileURL: URL(string: "file:///sample/tipografia.pdf")!),
        LibraryItem(title: "Cartas de invierno", format: .epub, author: "Mira Sol", progress: 0.23, fileURL: URL(string: "file:///sample/cartas.epub")!),
        LibraryItem(title: "Satélite 9", format: .cbz, progress: 0, fileURL: URL(string: "file:///sample/satelite.cbz")!),
        LibraryItem(title: "El archivo", format: .pdf, author: "Colección propia", progress: 1, fileURL: URL(string: "file:///sample/archivo.pdf")!)
    ]
}
import Foundation

struct LibraryItem: Identifiable, Hashable {
    let id: UUID
    var title: String
    var format: BookFormat
    var author: String?
    var progress: Double
    var lastOpened: Date?
    let createdAt: Date // Tu propiedad guardada

    // Modificamos el init para que acepte "createdAt" con un valor por defecto
    init(
        id: UUID = UUID(),
        title: String,
        format: BookFormat,
        author: String? = nil,
        progress: Double = 0,
        lastOpened: Date? = nil,
        createdAt: Date = Date() // NUEVO: Si no se envía fecha, toma la hora exacta actual
    ) {
        self.id = id
        self.title = title
        self.format = format
        self.author = author
        self.progress = progress
        self.lastOpened = lastOpened
        self.createdAt = createdAt // NUEVO: Se inicializa la propiedad obligatoria
    }
}

extension LibraryItem {
    static let samples: [LibraryItem] = [
        LibraryItem(title: "Noche en el muelle", format: .cbz, author: "Ana Ruiz", progress: 0.42),
        LibraryItem(title: "Circuitos", format: .cbr, author: "Leo Park", progress: 0.08),
        LibraryItem(title: "Tipografía viva", format: .pdf, author: "Estudio Norte", progress: 0.71),
        LibraryItem(title: "Cartas de invierno", format: .epub, author: "Mira Sol", progress: 0.23),
        LibraryItem(title: "Satélite 9", format: .cbz, progress: 0),
        LibraryItem(title: "El archivo", format: .pdf, author: "Colección propia", progress: 1)
    ]
}


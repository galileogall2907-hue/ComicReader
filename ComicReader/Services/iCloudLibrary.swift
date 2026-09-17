import Foundation

/// Punto de anclaje para documentos en iCloud Drive.
/// Requiere Team de Apple Developer y el capability iCloud Documents activo.
enum iCloudLibrary {
    static let containerIdentifier = "iCloud.com.luismandujano.ComicReader"

    static var documentsURL: URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: containerIdentifier)?
            .appendingPathComponent("Documents", isDirectory: true)
    }

    static let supportedExtensions: Set<String> = ["cbz", "cbr", "pdf", "epub"]
}

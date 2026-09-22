import Foundation
import UniformTypeIdentifiers
import Observation

@Observable
final class ImportService {
    private let store: LibraryStore
    private let fileManager = FileManager.default

    private var comicsDirectory: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = appSupport.appendingPathComponent("Comics", isDirectory: true)
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }

    init(store: LibraryStore) {
        self.store = store
    }

    var supportedUTTypes: [UTType] {
        [.cbz, .cbr, .pdf, .epub]
    }

    @MainActor
    func importFiles(from urls: [URL]) async -> ImportResult {
        var imported: [LibraryItem] = []
        var skipped: [URL] = []
        var failed: [(URL, Error)] = []

        for url in urls {
            if store.items.contains(where: { $0.fileURL == url }) {
                skipped.append(url)
                continue
            }

            guard let format = BookFormat.from(url: url) else {
                failed.append((url, ImportError.unsupportedFormat))
                continue
            }

            do {
                let destinationURL: URL
                if url.startAccessingSecurityScopedResource() {
                    defer { url.stopAccessingSecurityScopedResource() }
                    destinationURL = try copyToSandboxIfNeeded(url, format: format)
                } else {
                    destinationURL = try copyToSandboxIfNeeded(url, format: format)
                }

                let title = destinationURL.deletingPathExtension().lastPathComponent
                let item = LibraryItem(
                    title: title,
                    format: format,
                    author: nil,
                    progress: 0.0,
                    lastOpened: nil,
                    createdAt: Date(),
                    fileURL: destinationURL
                )

                store.items.insert(item, at: 0)
                imported.append(item)

            } catch {
                failed.append((url, error))
            }
        }

        return ImportResult(imported: imported, skipped: skipped, failed: failed)
    }

    private func copyToSandboxIfNeeded(_ url: URL, format: BookFormat) throws -> URL {
        let destURL = comicsDirectory.appendingPathComponent(url.lastPathComponent)
        if fileManager.fileExists(atPath: destURL.path) {
            return destURL
        }
        try fileManager.copyItem(at: url, to: destURL)
        return destURL
    }

    @MainActor
    func deleteItem(_ item: LibraryItem) {
        if item.fileURL.path.hasPrefix(comicsDirectory.path) {
            try? fileManager.removeItem(at: item.fileURL)
        }
        store.items.removeAll { $0.id == item.id }
    }
}

extension UTType {
    static let cbz = UTType(importedAs: "com.luismandujano.comicreader.cbz")
    static let cbr = UTType(importedAs: "com.luismandujano.comicreader.cbr")
}

enum ImportError: LocalizedError {
    case unsupportedFormat
    case copyFailed
    case securityScopedAccessDenied

    var errorDescription: String? {
        switch self {
        case .unsupportedFormat: return "Formato no soportado"
        case .copyFailed: return "No se pudo copiar el archivo"
        case .securityScopedAccessDenied: return "Permiso denegado para acceder al archivo"
        }
    }
}

struct ImportResult {
    let imported: [LibraryItem]
    let skipped: [URL]
    let failed: [(URL, Error)]

    var hasChanges: Bool { !imported.isEmpty }
    var summary: String {
        var parts: [String] = []
        if !imported.isEmpty { parts.append("\(imported.count) importados") }
        if !skipped.isEmpty { parts.append("\(skipped.count) duplicados") }
        if !failed.isEmpty { parts.append("\(failed.count) fallidos") }
        return parts.joined(separator: " • ")
    }
}
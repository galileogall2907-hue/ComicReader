import SwiftUI

struct LibraryEmptyState: View {
    var isSearching: Bool

    var body: some View {
        ContentUnavailableView {
            Label(
                isSearching ? "Sin resultados" : "Biblioteca vacía",
                systemImage: isSearching ? "magnifyingglass" : "books.vertical"
            )
        } description: {
            Text(
                isSearching
                    ? "Prueba con otro título, autor o formato."
                    : "Los archivos .cbz, .cbr, .pdf y .epub de iCloud Drive aparecerán aquí."
            )
        }
    }
}

import SwiftUI

struct ContentView: View {
    @Environment(LibraryStore.self) private var store
    @State private var searchText = ""
    @State private var showSortOptions = false

    private var filteredItems: [LibraryItem] {
        // 1. Primero filtramos por el texto de búsqueda
        let items = store.items(matching: searchText)

        // 2. Ordenamos usando una estructura explícita que Xcode entiende perfectamente
        let sortedItems = items.sorted { (first: LibraryItem, second: LibraryItem) -> Bool in
            switch sortOption {
                case .title:
                    return isAscending ? first.title < second.title : first.title > second.title
                case .progress:
                    return isAscending
                        ? first.progress < second.progress : first.progress > second.progress
                case .date:
                    // Si LibraryItem no tiene fecha, usamos un valor por defecto o fallback
                    let firstDate = first.createdAt
                    let secondDate = second.createdAt
                    return isAscending ? firstDate < secondDate : firstDate > secondDate
            }
        }

        return sortedItems
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 140, maximum: 220), spacing: 16, alignment: .top)]
    }

    // Estado para controlar el criterio de ordenamiento actual
    @State private var sortOption: SortOption = .title
    // Estado para controlar la dirección (Ascendente / Descendiente)
    @State private var isAscending: Bool = true

    // Enumeración con tus criterios de orden
    enum SortOption: String, CaseIterable, Identifiable {
        case title = "Nombre"
        case progress = "Avance de lectura"
        case date = "Fecha de carga"

        var id: String { self.rawValue }

        var icon: String {
            switch self {
                case .title: return "textformat"
                case .progress: return "chart.bar.fill"
                case .date: return "calendar"
            }
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredItems.isEmpty {
                    LibraryEmptyState(isSearching: !searchText.isEmpty)
                } else {
                    libraryGrid
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Biblioteca")
            .searchable(text: $searchText, prompt: "Título, autor o formato")
            .toolbar {
                // NUEVO: Botón de Ordenamiento
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        // Sección de Criterios
                        Section("Ordenar por") {
                            ForEach(SortOption.allCases) { option in
                                Button {
                                    sortOption = option
                                } label: {
                                    HStack {
                                        Text(option.rawValue)
                                        if sortOption == option {
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        }

                        // Sección de Dirección (Ascendente / Descendente)
                        Section {
                            Toggle(isOn: $isAscending) {
                                Label(
                                    isAscending ? "Ascendente" : "Descendente",
                                    systemImage: isAscending ? "arrow.up" : "arrow.down")
                            }
                        }
                    } label: {
                        // Icono dinámico que cambia según el orden seleccionado
                        Label("Ordenar", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }

                // Tu botón original de "+" se mantiene aquí abajo...
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        // Importación...
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Añadir libro")
                }
            }

        }
    }

    private var libraryGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(filteredItems) { item in
                    NavigationLink(value: item) {
                        LibraryItemCard(item: item)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .navigationDestination(for: LibraryItem.self) { item in
            Text(item.title)
                .navigationTitle(item.title)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview("Biblioteca") {
    ContentView()
        .environment(LibraryStore())
}

#Preview("Vacía") {
    ContentView()
        .environment(LibraryStore(items: [], usesSampleData: false))
}

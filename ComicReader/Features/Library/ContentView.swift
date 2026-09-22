import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(LibraryStore.self) private var store
    @Environment(ImportService.self) private var importService
    @State private var searchText = ""
    @State private var showSortOptions = false

    @State private var sortOption: SortOption = .title
    @State private var isAscending: Bool = true

    @State private var selectionMode = false
    @State private var selectedItems: Set<UUID> = []
    @State private var showRenameAlert = false
    @State private var newTitle = ""
    
    @State private var showDocumentPicker = false
    @State private var importResult: ImportResult?
    @State private var showImportResult = false

    private var filteredItems: [LibraryItem] {
        let items = store.items(matching: searchText)
        return items.sorted { (first, second) -> Bool in
            switch sortOption {
            case .title:
                return isAscending ? first.title < second.title : first.title > second.title
            case .progress:
                return isAscending ? first.progress < second.progress : first.progress > second.progress
            case .date:
                return isAscending ? first.createdAt < second.createdAt : first.createdAt > second.createdAt
            }
        }
    }

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 140, maximum: 220), spacing: 16, alignment: .top)]
    }

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
                ToolbarItem(placement: .primaryAction) {
                    Button(selectionMode ? "Cancelar" : "Seleccionar") {
                        selectionMode.toggle()
                        if !selectionMode { selectedItems.removeAll() }
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Section("Ordenar por") {
                            ForEach(SortOption.allCases) { option in
                                Button { sortOption = option } label: {
                                    HStack {
                                        Text(option.rawValue)
                                        if sortOption == option { Image(systemName: "checkmark") }
                                    }
                                }
                            }
                        }
                        Section {
                            Toggle(isOn: $isAscending) {
                                Label(isAscending ? "Ascendente" : "Descendente",
                                      systemImage: isAscending ? "arrow.up" : "arrow.down")
                            }
                        }
                    } label: {
                        Label("Ordenar", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }

                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showDocumentPicker = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Añadir libro")
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    if selectionMode && !selectedItems.isEmpty {
                        Menu("Acciones") {
                            if selectedItems.count == 1 {
                                Button { showRenameAlert = true } label: {
                                    Label("Renombrar", systemImage: "pencil")
                                }
                            }
                            Button {
                                for id in selectedItems {
                                    if let index = store.items.firstIndex(where: { $0.id == id }) {
                                        store.items[index].progress = 1.0
                                    }
                                }
                            } label: { Label("Marcar como leído", systemImage: "book.fill") }

                            Button {
                                for id in selectedItems {
                                    if let index = store.items.firstIndex(where: { $0.id == id }) {
                                        store.items[index].progress = 0.0
                                    }
                                }
                            } label: { Label("Marcar como no leído", systemImage: "book") }

                            Button(role: .destructive) {
                                store.items.removeAll { selectedItems.contains($0.id) }
                                selectedItems.removeAll()
                            } label: { Label("Eliminar", systemImage: "trash") }
                        }
                    }
                }
            }
            .alert("Renombrar", isPresented: $showRenameAlert) {
                TextField("Nuevo título", text: $newTitle)
                Button("Cancelar", role: .cancel) {}
                Button("Guardar") {
                    for id in selectedItems {
                        if let index = store.items.firstIndex(where: { $0.id == id }) {
                            store.items[index].title = newTitle
                        }
                    }
                    newTitle = ""
                    selectedItems.removeAll()
                }
            }
            .fileImporter(
                isPresented: $showDocumentPicker,
                allowedContentTypes: importService.supportedUTTypes,
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case .success(let urls):
                    Task {
                        let result = await importService.importFiles(from: urls)
                        importResult = result
                        showImportResult = result.hasChanges || !result.failed.isEmpty
                    }
                case .failure(let error):
                    importResult = ImportResult(imported: [], skipped: [], failed: [(URL(string: "")!, error)])
                    showImportResult = true
                }
            }
            .alert("Importación", isPresented: $showImportResult, presenting: importResult) { _ in
                Button("OK") {}
            } message: { result in
                Text(result.summary)
            }
        }
    }

    private var libraryGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(filteredItems) { item in
                    ZStack {
                        if selectionMode {
                            Button {
                                if selectedItems.contains(item.id) {
                                    selectedItems.remove(item.id)
                                } else {
                                    selectedItems.insert(item.id)
                                }
                            } label: {
                                LibraryItemCard(item: item)
                            }
                            .buttonStyle(.plain)

                            Image(systemName: selectedItems.contains(item.id) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(.blue)
                                .padding(6)
                                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        } else {
                            NavigationLink(value: item) {
                                LibraryItemCard(item: item)
                            }
                            .buttonStyle(.plain)
                        }

                        if item.progress == 0.0 {
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Label("Nuevo", systemImage: "sparkles")
                                        .font(.caption2)
                                        .fontWeight(.bold)
                                        .padding(6)
                                        .background(Color.orange)
                                        .foregroundColor(.white)
                                        .clipShape(Capsule())
                                        .padding(6)
                                }
                            }
                        }
                    }
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
        .environment(ImportService(store: LibraryStore()))
}

#Preview("Vacía") {
    ContentView()
        .environment(LibraryStore(items: [], usesSampleData: false))
        .environment(ImportService(store: LibraryStore(items: [], usesSampleData: false)))
}
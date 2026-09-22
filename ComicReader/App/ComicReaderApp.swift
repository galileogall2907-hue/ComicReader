import SwiftUI

@main
struct ComicReaderApp: App {
    @State private var store = LibraryStore()
    @State private var importService: ImportService

    init() {
        let store = LibraryStore()
        _store = State(initialValue: store)
        _importService = State(initialValue: ImportService(store: store))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .environment(importService)
        }
    }
}
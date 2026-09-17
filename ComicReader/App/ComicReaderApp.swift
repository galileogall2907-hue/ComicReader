import SwiftUI

@main
struct ComicReaderApp: App {
    @State private var store = LibraryStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}

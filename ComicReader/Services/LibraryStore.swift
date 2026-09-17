import Foundation
import Observation

@Observable
final class LibraryStore {
    var items: [LibraryItem]
    var usesSampleData: Bool

    init(items: [LibraryItem] = LibraryItem.samples, usesSampleData: Bool = true) {
        self.items = items
        self.usesSampleData = usesSampleData
    }

    func items(matching query: String) -> [LibraryItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return items }
        return items.filter {
            $0.title.localizedCaseInsensitiveContains(trimmed)
                || ($0.author?.localizedCaseInsensitiveContains(trimmed) ?? false)
                || $0.format.displayName.localizedCaseInsensitiveContains(trimmed)
        }
    }
}

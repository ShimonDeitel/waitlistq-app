import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var entries: [Entry] = []
    @Published var isProUnlocked: Bool = false

    /// Free tier allows up to this many entries. Deliberately kept well above
    /// the seed-data count (3) so a fresh install never trips the paywall.
    static let freeLimit = 30

    private let fileName = "waitlistq_entries.json"

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent(fileName)
    }

    init() {
        load()
    }

    var canAddMore: Bool {
        isProUnlocked || entries.count < Store.freeLimit
    }

    @discardableResult
    func add(_ entry: Entry) -> Bool {
        guard canAddMore else { return false }
        entries.insert(entry, at: 0)
        save()
        return true
    }

    func update(_ entry: Entry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx] = entry
        save()
    }

    func delete(_ entry: Entry) {
        entries.removeAll { $0.id == entry.id }
        save()
    }

    func delete(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func toggleFavorite(_ entry: Entry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        entries[idx].isFavorite.toggle()
        save()
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(entries)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Store save error: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else {
            entries = Store.seedData()
            save()
            return
        }
        if let decoded = try? JSONDecoder().decode([Entry].self, from: data) {
            entries = decoded
        } else {
            entries = Store.seedData()
        }
    }

    static func seedData() -> [Entry] {
        let now = Date()
        return [
            Entry(title: "Sample Client One", detail: "First example entry.", date: now),
            Entry(title: "Sample Client Two", detail: "Second example entry.", date: now.addingTimeInterval(-86400)),
            Entry(title: "Sample Client Three", detail: "Third example entry.", date: now.addingTimeInterval(-172800)),
        ]
    }
}

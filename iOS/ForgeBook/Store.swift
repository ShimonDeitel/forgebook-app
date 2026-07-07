import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [Session] = []
    @Published var isProUnlocked: Bool = false

    /// Free-tier cap. Seed data ships with 3 items, so this is set well above
    /// that to guarantee a fresh install never trips the paywall immediately.
    static let freeLimit = 15

    private let fileURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = support.appendingPathComponent("ForgeBook", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("sessions.json")
        load()
    }

    var isAtFreeLimit: Bool {
        !isProUnlocked && items.count >= Store.freeLimit
    }

    func canAdd() -> Bool {
        isProUnlocked || items.count < Store.freeLimit
    }

    func add(_ item: Session) {
        guard canAdd() else { return }
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: Session) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Session) {
        items.removeAll(where: { $0.id == item.id })
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Session].self, from: data) {
            items = decoded
        } else {
            items = Store.seedData
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static let seedData: [Session] = [
        Session(title: "Bottle Opener Batch", stockSize: "1/2in round mild steel", technique: "Draw taper, punch, twist", notes: "Forge welded loop, quench in oil"),
        Session(title: "Camp Hook", stockSize: "3/8in square", technique: "Scroll and hook bend", notes: "Normalized 3x before hardening"),
        Session(title: "Chef Knife Blank", stockSize: "1084 bar stock", technique: "Forged to shape, heat treat", notes: "Quenched at 1475F, tempered 2x")
    ]
}

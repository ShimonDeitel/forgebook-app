import Foundation

struct Session: Identifiable, Codable, Equatable {
    var id: UUID
    var createdAt: Date
    var title: String
    var stockSize: String
    var technique: String
    var notes: String

    init(id: UUID = UUID(), createdAt: Date = Date(), title: String = "", stockSize: String = "", technique: String = "", notes: String = "") {
        self.id = id
        self.createdAt = createdAt
        self.title = title
        self.stockSize = stockSize
        self.technique = technique
        self.notes = notes
    }
}

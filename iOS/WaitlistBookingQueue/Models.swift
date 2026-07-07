import Foundation

struct Entry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var title: String
    var detail: String
    var date: Date
    var isFavorite: Bool = false
}

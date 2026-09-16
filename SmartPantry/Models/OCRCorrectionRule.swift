import Foundation

public struct OCRCorrectionRule: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var originalRawText: String
    public var correctedName: String
    public var correctedCategory: ItemCategory
    public var correctedLocation: StorageLocation
    public var dateAdded: Date
    
    public init(
        id: UUID = UUID(),
        originalRawText: String,
        correctedName: String,
        correctedCategory: ItemCategory,
        correctedLocation: StorageLocation,
        dateAdded: Date = Date()
    ) {
        self.id = id
        self.originalRawText = originalRawText.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        self.correctedName = correctedName
        self.correctedCategory = correctedCategory
        self.correctedLocation = correctedLocation
        self.dateAdded = dateAdded
    }
}

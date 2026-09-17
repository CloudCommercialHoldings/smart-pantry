import Foundation
import SwiftUI

public enum ExpiryStatus: String, Codable {
    case fresh = "Fresh"
    case expiringSoon = "Expiring Soon"
    case expired = "Expired"
    
    public var badgeColor: Color {
        switch self {
        case .fresh: return Color.green
        case .expiringSoon: return Color.orange
        case .expired: return Color.red
        }
    }
}

public struct PantryItem: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var name: String
    public var normalizedName: String
    public var category: ItemCategory
    public var location: StorageLocation
    public var quantity: Double
    public var unit: String
    public var purchasePrice: Double?
    public var purchaseDate: Date
    public var expirationDate: Date
    public var barcode: String?
    public var notes: String?
    public var receiptId: UUID?
    public var isConsumed: Bool
    public var itemImageData: Data?
    
    public init(
        id: UUID = UUID(),
        name: String,
        normalizedName: String? = nil,
        category: ItemCategory = .produce,
        location: StorageLocation = .fridge,
        quantity: Double = 1.0,
        unit: String = "pcs",
        purchasePrice: Double? = nil,
        purchaseDate: Date = Date(),
        expirationDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
        barcode: String? = nil,
        notes: String? = nil,
        receiptId: UUID? = nil,
        isConsumed: Bool = false,
        itemImageData: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.normalizedName = normalizedName ?? name
        self.category = category
        self.location = location
        self.quantity = quantity
        self.unit = unit
        self.purchasePrice = purchasePrice
        self.purchaseDate = purchaseDate
        self.expirationDate = expirationDate
        self.barcode = barcode
        self.notes = notes
        self.receiptId = receiptId
        self.isConsumed = isConsumed
        self.itemImageData = itemImageData
    }
    
    public var daysUntilExpiration: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfExpiry = calendar.startOfDay(for: expirationDate)
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfExpiry)
        return components.day ?? 0
    }
    
    public var expiryStatus: ExpiryStatus {
        let days = daysUntilExpiration
        if days < 0 {
            return .expired
        } else if days <= 3 {
            return .expiringSoon
        } else {
            return .fresh
        }
    }
}

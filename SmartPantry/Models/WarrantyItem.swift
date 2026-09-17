import Foundation
import SwiftUI

public struct WarrantyItem: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var title: String
    public var storeName: String
    public var purchaseDate: Date
    public var warrantyMonths: Int
    public var expirationDate: Date
    public var receiptId: UUID?
    public var claimNotes: String?
    public var itemImageData: Data?
    
    public init(
        id: UUID = UUID(),
        title: String,
        storeName: String,
        purchaseDate: Date = Date(),
        warrantyMonths: Int = 12,
        expirationDate: Date? = nil,
        receiptId: UUID? = nil,
        claimNotes: String? = nil,
        itemImageData: Data? = nil
    ) {
        self.id = id
        self.title = title
        self.storeName = storeName
        self.purchaseDate = purchaseDate
        self.warrantyMonths = warrantyMonths
        if let exp = expirationDate {
            self.expirationDate = exp
        } else {
            self.expirationDate = Calendar.current.date(byAdding: .month, value: warrantyMonths, to: purchaseDate) ?? purchaseDate
        }
        self.receiptId = receiptId
        self.claimNotes = claimNotes
        self.itemImageData = itemImageData
    }
    
    public var daysUntilWarrantyExpiration: Int {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let startOfExpiry = calendar.startOfDay(for: expirationDate)
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfExpiry)
        return components.day ?? 0
    }
    
    public var isExpired: Bool {
        daysUntilWarrantyExpiration < 0
    }
    
    public var statusBadgeColor: Color {
        let days = daysUntilWarrantyExpiration
        if days < 0 { return .red }
        if days <= 30 { return .orange }
        return .green
    }
}

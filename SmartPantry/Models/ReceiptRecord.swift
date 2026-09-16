import Foundation
import SwiftUI

public enum OCRConfidence: String, Codable {
    case high = "High"
    case medium = "Needs Review"
    case low = "Uncertain"
    
    public var badgeColor: Color {
        switch self {
        case .high: return Color.green
        case .medium: return Color.orange
        case .low: return Color.red
        }
    }
}

public struct ReceiptItem: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var rawLine: String
    public var rawDescription: String
    public var normalizedName: String
    public var category: ItemCategory
    public var suggestedLocation: StorageLocation
    public var quantity: Double
    public var unitPrice: Double?
    public var totalPrice: Double
    public var confidence: OCRConfidence
    public var isConfirmedByUser: Bool
    public var isImportedToPantry: Bool
    
    public init(
        id: UUID = UUID(),
        rawLine: String,
        rawDescription: String,
        normalizedName: String,
        category: ItemCategory = .produce,
        suggestedLocation: StorageLocation = .fridge,
        quantity: Double = 1.0,
        unitPrice: Double? = nil,
        totalPrice: Double = 0.0,
        confidence: OCRConfidence = .high,
        isConfirmedByUser: Bool = false,
        isImportedToPantry: Bool = false
    ) {
        self.id = id
        self.rawLine = rawLine
        self.rawDescription = rawDescription
        self.normalizedName = normalizedName
        self.category = category
        self.suggestedLocation = suggestedLocation
        self.quantity = quantity
        self.unitPrice = unitPrice
        self.totalPrice = totalPrice
        self.confidence = confidence
        self.isConfirmedByUser = isConfirmedByUser
        self.isImportedToPantry = isImportedToPantry
    }
}

public struct ReceiptRecord: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var storeName: String
    public var purchaseDate: Date
    public var scanDate: Date
    public var subtotal: Double
    public var tax: Double
    public var totalAmount: Double
    public var savings: Double
    public var paymentMethod: String
    public var items: [ReceiptItem]
    public var rawText: String
    public var receiptImageData: Data?
    public var isDuplicate: Bool
    
    public init(
        id: UUID = UUID(),
        storeName: String = "Grocery Store",
        purchaseDate: Date = Date(),
        scanDate: Date = Date(),
        subtotal: Double = 0.0,
        tax: Double = 0.0,
        totalAmount: Double = 0.0,
        savings: Double = 0.0,
        paymentMethod: String = "Card",
        items: [ReceiptItem] = [],
        rawText: String = "",
        receiptImageData: Data? = nil,
        isDuplicate: Bool = false
    ) {
        self.id = id
        self.storeName = storeName
        self.purchaseDate = purchaseDate
        self.scanDate = scanDate
        self.subtotal = subtotal
        self.tax = tax
        self.totalAmount = totalAmount
        self.savings = savings
        self.paymentMethod = paymentMethod
        self.items = items
        self.rawText = rawText
        self.receiptImageData = receiptImageData
        self.isDuplicate = isDuplicate
    }
    
    public var itemCount: Int {
        items.count
    }
    
    public var uncertainItemCount: Int {
        items.filter { $0.confidence == .medium || $0.confidence == .low }.count
    }
}

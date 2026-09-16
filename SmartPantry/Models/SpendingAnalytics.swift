import Foundation

public struct CategorySpending: Identifiable, Equatable {
    public var id: String { category.rawValue }
    public let category: ItemCategory
    public let totalSpent: Double
    public let itemCount: Int
    public let percentage: Double
    
    public init(category: ItemCategory, totalSpent: Double, itemCount: Int, percentage: Double) {
        self.category = category
        self.totalSpent = totalSpent
        self.itemCount = itemCount
        self.percentage = percentage
    }
}

public struct StoreSpending: Identifiable, Equatable {
    public var id: String { storeName }
    public let storeName: String
    public let totalSpent: Double
    public let visitCount: Int
    
    public init(storeName: String, totalSpent: Double, visitCount: Int) {
        self.storeName = storeName
        self.totalSpent = totalSpent
        self.visitCount = visitCount
    }
}

public struct MonthlySpend: Identifiable, Equatable {
    public var id: String { monthYear }
    public let monthYear: String
    public let year: Int
    public let month: Int
    public let totalSpent: Double
    public let receiptCount: Int
    
    public init(monthYear: String, year: Int, month: Int, totalSpent: Double, receiptCount: Int) {
        self.monthYear = monthYear
        self.year = year
        self.month = month
        self.totalSpent = totalSpent
        self.receiptCount = receiptCount
    }
}

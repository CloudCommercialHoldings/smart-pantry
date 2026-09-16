import Foundation
import SwiftUI
import Combine

public class AnalyticsViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let storage: StorageService
    
    public init(storage: StorageService = .shared) {
        self.storage = storage
        storage.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    public var totalGrocerySpend: Double {
        storage.receipts.reduce(0.0) { $0 + $1.totalAmount }
    }
    
    public var totalReceiptsCount: Int {
        storage.receipts.count
    }
    
    public var averageTripSpend: Double {
        guard totalReceiptsCount > 0 else { return 0.0 }
        return totalGrocerySpend / Double(totalReceiptsCount)
    }
    
    public var categoryBreakdown: [CategorySpending] {
        var categoryTotals: [ItemCategory: (spend: Double, count: Int)] = [:]
        var overallSpent: Double = 0.0
        
        for receipt in storage.receipts {
            for item in receipt.items {
                let current = categoryTotals[item.category] ?? (0.0, 0)
                categoryTotals[item.category] = (current.spend + item.totalPrice, current.count + 1)
                overallSpent += item.totalPrice
            }
        }
        
        guard overallSpent > 0 else { return [] }
        
        return categoryTotals.map { (cat, val) in
            let pct = (val.spend / overallSpent) * 100.0
            return CategorySpending(category: cat, totalSpent: val.spend, itemCount: val.count, percentage: pct)
        }.sorted(by: { $0.totalSpent > $1.totalSpent })
    }
    
    public var storeLeaderboard: [StoreSpending] {
        var storeData: [String: (spend: Double, visits: Int)] = [:]
        
        for receipt in storage.receipts {
            let key = receipt.storeName
            let current = storeData[key] ?? (0.0, 0)
            storeData[key] = (current.spend + receipt.totalAmount, current.visits + 1)
        }
        
        return storeData.map { (store, val) in
            StoreSpending(storeName: store, totalSpent: val.spend, visitCount: val.visits)
        }.sorted(by: { $0.totalSpent > $1.totalSpent })
    }
    
    public var monthlyTrends: [MonthlySpend] {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        var monthlyData: [String: (year: Int, month: Int, spend: Double, count: Int)] = [:]
        let calendar = Calendar.current
        
        for receipt in storage.receipts {
            let key = formatter.string(from: receipt.purchaseDate)
            let comps = calendar.dateComponents([.year, .month], from: receipt.purchaseDate)
            let year = comps.year ?? 2026
            let month = comps.month ?? 1
            
            let current = monthlyData[key] ?? (year, month, 0.0, 0)
            monthlyData[key] = (year, month, current.spend + receipt.totalAmount, current.count + 1)
        }
        
        return monthlyData.map { (key, val) in
            MonthlySpend(monthYear: key, year: val.year, month: val.month, totalSpent: val.spend, receiptCount: val.count)
        }.sorted(by: {
            if $0.year != $1.year { return $0.year > $1.year }
            return $0.month > $1.month
        })
    }
    
    // MARK: - Waste Prevention Metrics
    
    public var activePantryItemCount: Int {
        storage.pantryItems.filter { !$0.isConsumed }.count
    }
    
    public var activePantryEstimatedValue: Double {
        storage.pantryItems.filter { !$0.isConsumed }.compactMap { $0.purchasePrice }.reduce(0.0, +)
    }
    
    public var consumedItemCount: Int {
        storage.pantryItems.filter { $0.isConsumed }.count
    }
    
    public var expiredItemCount: Int {
        storage.pantryItems.filter { !$0.isConsumed && $0.expiryStatus == .expired }.count
    }
    
    public var foodWasteSavedPercentage: Double {
        let totalTracked = consumedItemCount + expiredItemCount
        guard totalTracked > 0 else { return 100.0 }
        return (Double(consumedItemCount) / Double(totalTracked)) * 100.0
    }
}

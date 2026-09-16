import Foundation
import SwiftUI
import Combine

public enum DateRangeFilter: String, CaseIterable, Identifiable {
    case all = "All Time"
    case thisWeek = "This Week"
    case thisMonth = "This Month"
    case last3Months = "Past 3 Months"
    
    public var id: String { rawValue }
}

public class ReceiptHistoryViewModel: ObservableObject {
    @Published public var searchText: String = ""
    @Published public var selectedStoreFilter: String? = nil
    @Published public var selectedDateRange: DateRangeFilter = .all
    @Published public var selectedCategoryFilter: ItemCategory? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let storage: StorageService
    
    public init(storage: StorageService = .shared) {
        self.storage = storage
        storage.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    public var allStores: [String] {
        Array(Set(storage.receipts.map { $0.storeName })).sorted()
    }
    
    public var filteredReceipts: [ReceiptRecord] {
        var receipts = storage.receipts
        let calendar = Calendar.current
        let today = Date()
        
        // Date Range Filter
        switch selectedDateRange {
        case .all:
            break
        case .thisWeek:
            if let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)) {
                receipts = receipts.filter { $0.purchaseDate >= startOfWeek }
            }
        case .thisMonth:
            if let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today)) {
                receipts = receipts.filter { $0.purchaseDate >= startOfMonth }
            }
        case .last3Months:
            if let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: today) {
                receipts = receipts.filter { $0.purchaseDate >= threeMonthsAgo }
            }
        }
        
        // Store Filter
        if let store = selectedStoreFilter {
            receipts = receipts.filter { $0.storeName.lowercased() == store.lowercased() }
        }
        
        // Category Filter
        if let cat = selectedCategoryFilter {
            receipts = receipts.filter { receipt in
                receipt.items.contains(where: { $0.category == cat })
            }
        }
        
        // Search Query
        if !searchText.isEmpty {
            let q = searchText.lowercased()
            receipts = receipts.filter { receipt in
                receipt.storeName.lowercased().contains(q) ||
                receipt.items.contains(where: { $0.normalizedName.lowercased().contains(q) || $0.rawDescription.lowercased().contains(q) })
            }
        }
        
        return receipts.sorted(by: { $0.purchaseDate > $1.purchaseDate })
    }
    
    public var totalSpentInFiltered: Double {
        filteredReceipts.reduce(0.0) { $0 + $1.totalAmount }
    }
    
    public var averageSpendPerReceipt: Double {
        guard !filteredReceipts.isEmpty else { return 0.0 }
        return totalSpentInFiltered / Double(filteredReceipts.count)
    }
    
    public func deleteReceipt(_ receipt: ReceiptRecord) {
        storage.deleteReceiptRecord(receipt)
    }
    
    public func updateReceipt(_ receipt: ReceiptRecord) {
        storage.updateReceiptRecord(receipt)
    }
}

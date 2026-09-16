import Foundation
import SwiftUI
import Combine

public enum PantrySortOption: String, CaseIterable, Identifiable {
    case expirationDate = "Expiration Date"
    case purchaseDate = "Date Added"
    case name = "Name (A-Z)"
    case category = "Category"
    
    public var id: String { rawValue }
}

public class PantryViewModel: ObservableObject {
    @Published public var selectedLocation: StorageLocation? = nil
    @Published public var selectedCategory: ItemCategory? = nil
    @Published public var selectedExpiryFilter: ExpiryStatus? = nil
    @Published public var searchText: String = ""
    @Published public var sortOption: PantrySortOption = .expirationDate
    @Published public var showConsumedItems: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let storage: StorageService
    
    public init(storage: StorageService = .shared) {
        self.storage = storage
        
        // Forward changes from StorageService
        storage.objectWillChange.sink { [weak self] _ in
            self?.objectWillChange.send()
        }.store(in: &cancellables)
    }
    
    public var filteredItems: [PantryItem] {
        var items = storage.pantryItems.filter { $0.isConsumed == showConsumedItems }
        
        if let location = selectedLocation {
            items = items.filter { $0.location == location }
        }
        
        if let category = selectedCategory {
            items = items.filter { $0.category == category }
        }
        
        if let expiryFilter = selectedExpiryFilter {
            items = items.filter { $0.expiryStatus == expiryFilter }
        }
        
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            items = items.filter {
                $0.name.lowercased().contains(query) ||
                $0.normalizedName.lowercased().contains(query) ||
                $0.category.rawValue.lowercased().contains(query) ||
                $0.location.rawValue.lowercased().contains(query)
            }
        }
        
        switch sortOption {
        case .expirationDate:
            return items.sorted(by: { $0.expirationDate < $1.expirationDate })
        case .purchaseDate:
            return items.sorted(by: { $0.purchaseDate > $1.purchaseDate })
        case .name:
            return items.sorted(by: { $0.name.localizedCompare($1.name) == .orderedAscending })
        case .category:
            return items.sorted(by: { $0.category.rawValue < $1.category.rawValue })
        }
    }
    
    public var expiringSoonCount: Int {
        storage.pantryItems.filter { !$0.isConsumed && $0.expiryStatus == .expiringSoon }.count
    }
    
    public var expiredCount: Int {
        storage.pantryItems.filter { !$0.isConsumed && $0.expiryStatus == .expired }.count
    }
    
    public var freshCount: Int {
        storage.pantryItems.filter { !$0.isConsumed && $0.expiryStatus == .fresh }.count
    }
    
    // MARK: - Actions
    
    public func addItem(_ item: PantryItem) {
        storage.addPantryItem(item)
    }
    
    public func updateItem(_ item: PantryItem) {
        storage.updatePantryItem(item)
    }
    
    public func deleteItem(_ item: PantryItem) {
        storage.deletePantryItem(item)
    }
    
    public func markConsumed(_ item: PantryItem) {
        storage.markAsConsumed(item)
    }
    
    public func extendExpiration(for item: PantryItem, byDays days: Int) {
        var updated = item
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: item.expirationDate) {
            updated.expirationDate = newDate
            storage.updatePantryItem(updated)
        }
    }
    
    public func moveLocation(for item: PantryItem, to newLocation: StorageLocation) {
        var updated = item
        updated.location = newLocation
        storage.updatePantryItem(updated)
    }
}

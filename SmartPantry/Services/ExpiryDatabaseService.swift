import Foundation

public class ExpiryDatabaseService {
    public static let shared = ExpiryDatabaseService()
    
    struct ShelfLifeRule {
        let daysInFridge: Int
        let daysInFreezer: Int
        let daysInPantry: Int
        let category: ItemCategory
        let defaultLocation: StorageLocation
    }
    
    private var rules: [String: ShelfLifeRule] = [
        // Produce
        "milk": ShelfLifeRule(daysInFridge: 7, daysInFreezer: 30, daysInPantry: 0, category: .dairy, defaultLocation: .fridge),
        "banana": ShelfLifeRule(daysInFridge: 3, daysInFreezer: 60, daysInPantry: 5, category: .produce, defaultLocation: .pantry),
        "apple": ShelfLifeRule(daysInFridge: 21, daysInFreezer: 180, daysInPantry: 7, category: .produce, defaultLocation: .fridge),
        "avocado": ShelfLifeRule(daysInFridge: 7, daysInFreezer: 60, daysInPantry: 4, category: .produce, defaultLocation: .pantry),
        "spinach": ShelfLifeRule(daysInFridge: 5, daysInFreezer: 90, daysInPantry: 1, category: .produce, defaultLocation: .fridge),
        "kale": ShelfLifeRule(daysInFridge: 7, daysInFreezer: 90, daysInPantry: 1, category: .produce, defaultLocation: .fridge),
        "lettuce": ShelfLifeRule(daysInFridge: 7, daysInFreezer: 0, daysInPantry: 1, category: .produce, defaultLocation: .fridge),
        "tomato": ShelfLifeRule(daysInFridge: 7, daysInFreezer: 60, daysInPantry: 5, category: .produce, defaultLocation: .pantry),
        "strawberry": ShelfLifeRule(daysInFridge: 5, daysInFreezer: 180, daysInPantry: 1, category: .produce, defaultLocation: .fridge),
        "blueberry": ShelfLifeRule(daysInFridge: 10, daysInFreezer: 180, daysInPantry: 2, category: .produce, defaultLocation: .fridge),
        "raspberry": ShelfLifeRule(daysInFridge: 3, daysInFreezer: 180, daysInPantry: 1, category: .produce, defaultLocation: .fridge),
        "carrot": ShelfLifeRule(daysInFridge: 28, daysInFreezer: 180, daysInPantry: 7, category: .produce, defaultLocation: .fridge),
        "broccoli": ShelfLifeRule(daysInFridge: 7, daysInFreezer: 180, daysInPantry: 2, category: .produce, defaultLocation: .fridge),
        "potato": ShelfLifeRule(daysInFridge: 30, daysInFreezer: 180, daysInPantry: 21, category: .produce, defaultLocation: .pantry),
        "onion": ShelfLifeRule(daysInFridge: 30, daysInFreezer: 180, daysInPantry: 30, category: .produce, defaultLocation: .pantry),
        "garlic": ShelfLifeRule(daysInFridge: 60, daysInFreezer: 180, daysInPantry: 90, category: .produce, defaultLocation: .pantry),
        "lemon": ShelfLifeRule(daysInFridge: 21, daysInFreezer: 120, daysInPantry: 7, category: .produce, defaultLocation: .fridge),
        "lime": ShelfLifeRule(daysInFridge: 21, daysInFreezer: 120, daysInPantry: 7, category: .produce, defaultLocation: .fridge),
        
        // Meat & Seafood
        "chicken": ShelfLifeRule(daysInFridge: 3, daysInFreezer: 180, daysInPantry: 0, category: .meatSeafood, defaultLocation: .fridge),
        "beef": ShelfLifeRule(daysInFridge: 4, daysInFreezer: 180, daysInPantry: 0, category: .meatSeafood, defaultLocation: .fridge),
        "steak": ShelfLifeRule(daysInFridge: 4, daysInFreezer: 180, daysInPantry: 0, category: .meatSeafood, defaultLocation: .fridge),
        "ground beef": ShelfLifeRule(daysInFridge: 2, daysInFreezer: 120, daysInPantry: 0, category: .meatSeafood, defaultLocation: .fridge),
        "pork": ShelfLifeRule(daysInFridge: 4, daysInFreezer: 180, daysInPantry: 0, category: .meatSeafood, defaultLocation: .fridge),
        "bacon": ShelfLifeRule(daysInFridge: 10, daysInFreezer: 30, daysInPantry: 0, category: .meatSeafood, defaultLocation: .fridge),
        "turkey": ShelfLifeRule(daysInFridge: 3, daysInFreezer: 180, daysInPantry: 0, category: .meatSeafood, defaultLocation: .fridge),
        "salmon": ShelfLifeRule(daysInFridge: 2, daysInFreezer: 90, daysInPantry: 0, category: .meatSeafood, defaultLocation: .fridge),
        "shrimp": ShelfLifeRule(daysInFridge: 2, daysInFreezer: 180, daysInPantry: 0, category: .meatSeafood, defaultLocation: .fridge),
        "tuna": ShelfLifeRule(daysInFridge: 2, daysInFreezer: 90, daysInPantry: 365, category: .meatSeafood, defaultLocation: .fridge),
        "sausage": ShelfLifeRule(daysInFridge: 5, daysInFreezer: 60, daysInPantry: 0, category: .meatSeafood, defaultLocation: .fridge),
        
        // Dairy & Eggs
        "egg": ShelfLifeRule(daysInFridge: 28, daysInFreezer: 0, daysInPantry: 2, category: .dairy, defaultLocation: .fridge),
        "cheese": ShelfLifeRule(daysInFridge: 21, daysInFreezer: 180, daysInPantry: 0, category: .dairy, defaultLocation: .fridge),
        "cheddar": ShelfLifeRule(daysInFridge: 30, daysInFreezer: 180, daysInPantry: 0, category: .dairy, defaultLocation: .fridge),
        "yogurt": ShelfLifeRule(daysInFridge: 14, daysInFreezer: 30, daysInPantry: 0, category: .dairy, defaultLocation: .fridge),
        "butter": ShelfLifeRule(daysInFridge: 60, daysInFreezer: 270, daysInPantry: 2, category: .dairy, defaultLocation: .fridge),
        "cream": ShelfLifeRule(daysInFridge: 10, daysInFreezer: 30, daysInPantry: 0, category: .dairy, defaultLocation: .fridge),
        
        // Bakery
        "bread": ShelfLifeRule(daysInFridge: 14, daysInFreezer: 90, daysInPantry: 6, category: .bakery, defaultLocation: .pantry),
        "bagel": ShelfLifeRule(daysInFridge: 14, daysInFreezer: 90, daysInPantry: 5, category: .bakery, defaultLocation: .pantry),
        "tortilla": ShelfLifeRule(daysInFridge: 30, daysInFreezer: 180, daysInPantry: 14, category: .bakery, defaultLocation: .pantry),
        
        // Canned & Dry Goods
        "rice": ShelfLifeRule(daysInFridge: 180, daysInFreezer: 365, daysInPantry: 365, category: .cannedGoods, defaultLocation: .pantry),
        "pasta": ShelfLifeRule(daysInFridge: 180, daysInFreezer: 365, daysInPantry: 365, category: .cannedGoods, defaultLocation: .pantry),
        "beans": ShelfLifeRule(daysInFridge: 5, daysInFreezer: 180, daysInPantry: 365, category: .cannedGoods, defaultLocation: .pantry),
        "soup": ShelfLifeRule(daysInFridge: 4, daysInFreezer: 90, daysInPantry: 365, category: .cannedGoods, defaultLocation: .pantry)
    ]
    
    public init() {}
    
    /// Auto-detects category, suggested location, and suggested expiration date for an item name
    public func predictMetadata(itemName: String, location: StorageLocation? = nil) -> (category: ItemCategory, location: StorageLocation, expirationDate: Date) {
        let cleanName = itemName.lowercased()
        
        var matchedRule: ShelfLifeRule? = nil
        for (key, rule) in rules {
            if cleanName.contains(key) {
                matchedRule = rule
                break
            }
        }
        
        let selectedCategory = matchedRule?.category ?? inferCategory(from: cleanName)
        let selectedLocation = location ?? matchedRule?.defaultLocation ?? inferLocation(from: selectedCategory)
        
        let daysToAdd: Int
        if let rule = matchedRule {
            switch selectedLocation {
            case .fridge: daysToAdd = rule.daysInFridge
            case .freezer: daysToAdd = rule.daysInFreezer
            case .pantry: daysToAdd = rule.daysInPantry
            case .spiceRack: daysToAdd = 365
            }
        } else {
            daysToAdd = defaultDays(for: selectedCategory, location: selectedLocation)
        }
        
        let expirationDate = Calendar.current.date(byAdding: .day, value: max(daysToAdd, 1), to: Date()) ?? Date()
        return (selectedCategory, selectedLocation, expirationDate)
    }
    
    private func inferCategory(from name: String) -> ItemCategory {
        if name.contains("milk") || name.contains("cheese") || name.contains("yogurt") || name.contains("butter") || name.contains("cream") || name.contains("egg") {
            return .dairy
        } else if name.contains("chicken") || name.contains("beef") || name.contains("pork") || name.contains("steak") || name.contains("salmon") || name.contains("bacon") || name.contains("turkey") {
            return .meatSeafood
        } else if name.contains("apple") || name.contains("banana") || name.contains("berry") || name.contains("lettuce") || name.contains("spinach") || name.contains("tomato") || name.contains("onion") || name.contains("avocado") {
            return .produce
        } else if name.contains("bread") || name.contains("bagel") || name.contains("croissant") || name.contains("muffin") || name.contains("cake") {
            return .bakery
        } else if name.contains("pizza") || name.contains("ice cream") || name.contains("waffle") || name.contains("frozen") {
            return .frozen
        } else if name.contains("juice") || name.contains("soda") || name.contains("water") || name.contains("coffee") || name.contains("tea") || name.contains("beer") || name.contains("wine") {
            return .beverages
        } else if name.contains("chip") || name.contains("cookie") || name.contains("snack") || name.contains("chocolate") || name.contains("nut") {
            return .snacks
        } else if name.contains("pepper") || name.contains("salt") || name.contains("sauce") || name.contains("ketchup") || name.contains("mustard") || name.contains("spice") {
            return .condiments
        } else if name.contains("can") || name.contains("soup") || name.contains("cereal") || name.contains("oat") || name.contains("rice") || name.contains("pasta") {
            return .cannedGoods
        }
        return .produce
    }
    
    private func inferLocation(from category: ItemCategory) -> StorageLocation {
        switch category {
        case .produce: return .fridge
        case .dairy: return .fridge
        case .meatSeafood: return .fridge
        case .bakery: return .pantry
        case .frozen: return .freezer
        case .beverages: return .fridge
        case .snacks: return .pantry
        case .cannedGoods: return .pantry
        case .condiments: return .pantry
        case .household: return .pantry
        }
    }
    
    private func defaultDays(for category: ItemCategory, location: StorageLocation) -> Int {
        switch location {
        case .freezer: return 90
        case .fridge:
            switch category {
            case .meatSeafood: return 3
            case .produce: return 7
            case .dairy: return 10
            case .bakery: return 10
            default: return 14
            }
        case .pantry:
            switch category {
            case .bakery: return 5
            case .produce: return 4
            case .cannedGoods: return 180
            case .snacks: return 30
            default: return 14
            }
        case .spiceRack: return 365
        }
    }
}

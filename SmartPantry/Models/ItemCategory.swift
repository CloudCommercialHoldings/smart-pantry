import Foundation
import SwiftUI

public enum ItemCategory: String, Codable, CaseIterable, Identifiable {
    case produce = "Produce"
    case dairy = "Dairy & Eggs"
    case meatSeafood = "Meat & Seafood"
    case bakery = "Bakery & Bread"
    case frozen = "Frozen Foods"
    case beverages = "Beverages"
    case snacks = "Snacks & Sweets"
    case cannedGoods = "Canned & Dry Goods"
    case condiments = "Condiments & Spices"
    case household = "Household & Other"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .produce: return "leaf.fill"
        case .dairy: return "cup.and.saucer.fill"
        case .meatSeafood: return "fork.knife"
        case .bakery: return "birthday.cake.fill"
        case .frozen: return "snowflake"
        case .beverages: return "wineglass.fill"
        case .snacks: return "popcorn.fill"
        case .cannedGoods: return "cylinder.split.1x2.fill"
        case .condiments: return "takeoutbag.and.cup.and.straw.fill"
        case .household: return "house.fill"
        }
    }
    
    public var categoryColor: Color {
        switch self {
        case .produce: return Color.green
        case .dairy: return Color.blue
        case .meatSeafood: return Color.red
        case .bakery: return Color.orange
        case .frozen: return Color.teal
        case .beverages: return Color.purple
        case .snacks: return Color.pink
        case .cannedGoods: return Color.brown
        case .condiments: return Color.yellow
        case .household: return Color.gray
        }
    }
}

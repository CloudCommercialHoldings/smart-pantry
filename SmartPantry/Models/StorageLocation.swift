import Foundation
import SwiftUI

public enum StorageLocation: String, Codable, CaseIterable, Identifiable {
    case fridge = "Fridge"
    case freezer = "Freezer"
    case pantry = "Pantry"
    case spiceRack = "Spice Rack"
    
    public var id: String { rawValue }
    
    public var iconName: String {
        switch self {
        case .fridge: return "refrigerator"
        case .freezer: return "snowflake"
        case .pantry: return "cabinet.fill"
        case .spiceRack: return "flame.fill"
        }
    }
    
    public var themeColor: Color {
        switch self {
        case .fridge: return Color.cyan
        case .freezer: return Color.blue
        case .pantry: return Color.orange
        case .spiceRack: return Color.red
        }
    }
}

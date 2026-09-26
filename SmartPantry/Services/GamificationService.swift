import Foundation
import SwiftUI
import Combine

public enum PantryLevel: String, Codable, CaseIterable {
    case entry = "Entry Pantry"
    case midLevel = "Mid-Level Pantry"
    case master = "Master Pantry Expert"
    
    public var badgeTitle: String { rawValue }
    
    public var badgeIcon: String {
        switch self {
        case .entry: return "leaf.fill"
        case .midLevel: return "star.fill"
        case .master: return "crown.fill"
        }
    }
    
    public var badgeColor: Color {
        switch self {
        case .entry: return .green
        case .midLevel: return .blue
        case .master: return .purple
        }
    }
    
    public var criteriaDescription: String {
        switch self {
        case .entry: return "Logs receipts weekly (1+ receipts logged)"
        case .midLevel: return "Consistently enters monthly receipts (3+ receipts logged)"
        case .master: return "Logs monthly receipts and cleans up pantry (5+ receipts & 3+ cleanups)"
        }
    }
}

public struct GiftCardReward: Identifiable, Codable, Equatable {
    public let id: UUID
    public let storeName: String
    public let amount: String
    public let code: String
    public var isClaimed: Bool
    public var claimedDate: Date?
    public let expiryNotice: String
    public let iconName: String
    public let storeColorHex: String
    
    public init(
        id: UUID = UUID(),
        storeName: String,
        amount: String = "$10.00",
        code: String,
        isClaimed: Bool = false,
        claimedDate: Date? = nil,
        expiryNotice: String = "Valid for 12 months at any checkout register or online.",
        iconName: String,
        storeColorHex: String
    ) {
        self.id = id
        self.storeName = storeName
        self.amount = amount
        self.code = code
        self.isClaimed = isClaimed
        self.claimedDate = claimedDate
        self.expiryNotice = expiryNotice
        self.iconName = iconName
        self.storeColorHex = storeColorHex
    }
}

public class GamificationService: ObservableObject {
    public static let shared = GamificationService()
    
    @Published public var receiptsThisWeek: Int = 0
    @Published public var receiptsThisMonth: Int = 0
    @Published public var totalReceiptsLogged: Int = 0
    @Published public var pantryCleanupsCount: Int = 0
    @Published public var availableGiftCards: [GiftCardReward] = []
    @Published public var claimedGiftCards: [GiftCardReward] = []
    
    private let statsKey = "smartpantry_gamification_stats"
    private let rewardsKey = "smartpantry_rewards_catalog"
    
    public init() {
        loadData()
        let usesRetailerCards = availableGiftCards.contains(where: {
            ["Walmart", "Walgreens", "Target"].contains($0.storeName)
        }) || claimedGiftCards.contains(where: {
            ["Walmart", "Walgreens", "Target"].contains($0.storeName)
        })
        if availableGiftCards.isEmpty || usesRetailerCards {
            claimedGiftCards.removeAll { ["Walmart", "Walgreens", "Target"].contains($0.storeName) }
            seedGiftCards()
        }
    }
    
    public var currentLevel: PantryLevel {
        if totalReceiptsLogged >= 5 && pantryCleanupsCount >= 3 {
            return .master
        } else if totalReceiptsLogged >= 3 || receiptsThisMonth >= 2 {
            return .midLevel
        } else {
            return .entry
        }
    }
    
    public var isMasterUnlocked: Bool {
        return currentLevel == .master
    }
    
    public var progressToMaster: Double {
        let receiptsProgress = min(Double(totalReceiptsLogged) / 5.0, 1.0)
        let cleanupProgress = min(Double(pantryCleanupsCount) / 3.0, 1.0)
        return (receiptsProgress + cleanupProgress) / 2.0
    }
    
    // MARK: - Actions
    
    public func recordReceiptLogged() {
        totalReceiptsLogged += 1
        receiptsThisWeek += 1
        receiptsThisMonth += 1
        saveData()
    }
    
    public func recordPantryCleanup() {
        pantryCleanupsCount += 1
        saveData()
    }
    
    public func claimGiftCard(_ card: GiftCardReward) {
        if let idx = availableGiftCards.firstIndex(where: { $0.id == card.id }) {
            var updated = availableGiftCards[idx]
            updated.isClaimed = true
            updated.claimedDate = Date()
            availableGiftCards.remove(at: idx)
            claimedGiftCards.insert(updated, at: 0)
            saveData()
        }
    }
    
    // MARK: - Persistence
    
    private func loadData() {
        let defaults = UserDefaults.standard
        totalReceiptsLogged = defaults.integer(forKey: "\(statsKey)_receipts")
        pantryCleanupsCount = defaults.integer(forKey: "\(statsKey)_cleanups")
        receiptsThisWeek = max(defaults.integer(forKey: "\(statsKey)_receipts_week"), totalReceiptsLogged > 0 ? 1 : 0)
        receiptsThisMonth = max(defaults.integer(forKey: "\(statsKey)_receipts_month"), totalReceiptsLogged > 0 ? 2 : 0)
        
        if let data = defaults.data(forKey: "\(rewardsKey)_available"),
           let cards = try? JSONDecoder().decode([GiftCardReward].self, from: data) {
            self.availableGiftCards = cards
        }
        
        if let data = defaults.data(forKey: "\(rewardsKey)_claimed"),
           let cards = try? JSONDecoder().decode([GiftCardReward].self, from: data) {
            self.claimedGiftCards = cards
        }
    }
    
    private func saveData() {
        let defaults = UserDefaults.standard
        defaults.set(totalReceiptsLogged, forKey: "\(statsKey)_receipts")
        defaults.set(pantryCleanupsCount, forKey: "\(statsKey)_cleanups")
        defaults.set(receiptsThisWeek, forKey: "\(statsKey)_receipts_week")
        defaults.set(receiptsThisMonth, forKey: "\(statsKey)_receipts_month")
        
        if let data = try? JSONEncoder().encode(availableGiftCards) {
            defaults.set(data, forKey: "\(rewardsKey)_available")
        }
        if let data = try? JSONEncoder().encode(claimedGiftCards) {
            defaults.set(data, forKey: "\(rewardsKey)_claimed")
        }
    }
    
    private func seedGiftCards() {
        self.availableGiftCards = [
            GiftCardReward(
                storeName: "Zero-Waste Badge",
                amount: "Unlocked",
                code: "PANTRY-BADGE-01",
                expiryNotice: "In-app achievement only. Not a store gift card and has no cash value.",
                iconName: "leaf.circle.fill",
                storeColorHex: "#2E7D32"
            ),
            GiftCardReward(
                storeName: "Expiry Hero Badge",
                amount: "Unlocked",
                code: "PANTRY-BADGE-02",
                expiryNotice: "In-app achievement only. Not a store gift card and has no cash value.",
                iconName: "clock.badge.checkmark.fill",
                storeColorHex: "#1565C0"
            ),
            GiftCardReward(
                storeName: "Receipt Master Badge",
                amount: "Unlocked",
                code: "PANTRY-BADGE-03",
                expiryNotice: "In-app achievement only. Not a store gift card and has no cash value.",
                iconName: "doc.viewfinder.fill",
                storeColorHex: "#6A1B9A"
            )
        ]
        saveData()
    }
}

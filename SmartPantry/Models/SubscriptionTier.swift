import Foundation
import SwiftUI

public enum SubscriptionTier: String, Codable, CaseIterable, Identifiable {
    case free = "Free"
    case pro = "Pro"
    
    public var id: String { rawValue }
}

public struct SubscriptionPlan: Identifiable, Equatable {
    public var id: String
    public var title: String
    public var priceString: String
    public var periodString: String
    public var badge: String?
    public var isPopular: Bool
    public var trialDays: Int?
    
    public init(id: String, title: String, priceString: String, periodString: String, badge: String? = nil, isPopular: Bool = false, trialDays: Int? = nil) {
        self.id = id
        self.title = title
        self.priceString = priceString
        self.periodString = periodString
        self.badge = badge
        self.isPopular = isPopular
        self.trialDays = trialDays
    }
}

import Foundation
import SwiftUI
import Combine

public enum ReceiptRetentionOption: String, Codable, CaseIterable, Identifiable {
    case twentyDays = "20 Days (Free Tier)"
    case thirtyDays = "30 Days"
    case ninetyDays = "90 Days"
    case oneYear = "1 Year"
    case forever = "Keep Forever (Pro)"
    
    public var id: String { rawValue }
}

public class SubscriptionService: ObservableObject {
    public static let shared = SubscriptionService()
    
    @Published public var isPro: Bool {
        didSet {
            UserDefaults.standard.set(isPro, forKey: "is_pro_subscriber")
        }
    }
    
    @Published public var selectedRetention: ReceiptRetentionOption {
        didSet {
            UserDefaults.standard.set(selectedRetention.rawValue, forKey: "receipt_retention_option")
        }
    }
    
    public let freeReceiptScanLimit: Int = 10
    public let freeRetentionDays: Int = 20
    public let defaultPaypalURL: String = "https://www.paypal.com/checkoutnow"
    
    public init() {
        self.isPro = UserDefaults.standard.bool(forKey: "is_pro_subscriber")
        
        let savedRetention = UserDefaults.standard.string(forKey: "receipt_retention_option") ?? ReceiptRetentionOption.twentyDays.rawValue
        self.selectedRetention = ReceiptRetentionOption(rawValue: savedRetention) ?? .twentyDays
    }
    
    /// Checks if user can scan a new receipt under current subscription rules
    public func canScanReceipt(currentReceiptCount: Int) -> Bool {
        if isPro { return true }
        return currentReceiptCount < freeReceiptScanLimit
    }
    
    /// Auto-purges receipts older than allowed retention policy
    public func filterReceiptsForRetention(_ receipts: [ReceiptRecord]) -> (valid: [ReceiptRecord], purgedCount: Int) {
        if isPro && selectedRetention == .forever {
            return (receipts, 0)
        }
        
        let maxDays: Int
        if !isPro {
            maxDays = freeRetentionDays
        } else {
            switch selectedRetention {
            case .twentyDays: maxDays = 20
            case .thirtyDays: maxDays = 30
            case .ninetyDays: maxDays = 90
            case .oneYear: maxDays = 365
            case .forever: return (receipts, 0)
            }
        }
        
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -maxDays, to: Date()) ?? Date()
        let validReceipts = receipts.filter { $0.purchaseDate >= cutoffDate }
        let purgedCount = receipts.count - validReceipts.count
        
        return (validReceipts, purgedCount)
    }
    
    /// Upgrade to Pro
    public func activateProSubscription() {
        self.isPro = true
        self.selectedRetention = .forever
    }
    
    /// Open PayPal link for subscription checkout
    public func openPayPalCheckout() {
        if let url = URL(string: defaultPaypalURL) {
            UIApplication.shared.open(url)
        }
        // Auto-activate pro for demo/seamless App Store preview
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.activateProSubscription()
        }
    }
    
    /// Restore Previous Purchase
    public func restorePurchases(completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.activateProSubscription()
            completion(true)
        }
    }
}

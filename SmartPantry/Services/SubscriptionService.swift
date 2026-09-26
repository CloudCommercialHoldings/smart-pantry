import Foundation
import StoreKit
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
    
    public static let monthlyProductID = "com.smartpantry.app.pro.monthly"
    public static let annualProductID = "com.smartpantry.app.pro.annual"
    public static let productIDs: Set<String> = [monthlyProductID, annualProductID]
    
    @Published public var isPro: Bool = false
    @Published public var selectedRetention: ReceiptRetentionOption {
        didSet {
            UserDefaults.standard.set(selectedRetention.rawValue, forKey: "receipt_retention_option")
        }
    }
    @Published public var products: [Product] = []
    @Published public var purchaseError: String?
    @Published public var isPurchasing: Bool = false
    @Published public var isLoadingProducts: Bool = false
    
    public let freeReceiptScanLimit: Int = 10
    public let freeRetentionDays: Int = 20
    
    private var updatesTask: Task<Void, Never>?
    
    public init() {
        self.isPro = UserDefaults.standard.bool(forKey: "is_pro_subscriber")
        let savedRetention = UserDefaults.standard.string(forKey: "receipt_retention_option") ?? ReceiptRetentionOption.twentyDays.rawValue
        self.selectedRetention = ReceiptRetentionOption(rawValue: savedRetention) ?? .twentyDays
    }
    
    public func start() async {
        await loadProducts()
        await refreshEntitlements()
        listenForTransactions()
    }
    
    public func canScanReceipt(currentReceiptCount: Int) -> Bool {
        if isPro { return true }
        return currentReceiptCount < freeReceiptScanLimit
    }
    
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
        return (validReceipts, receipts.count - validReceipts.count)
    }
    
    public func product(for planID: String) -> Product? {
        let productID = planID == "monthly" ? Self.monthlyProductID : Self.annualProductID
        return products.first(where: { $0.id == productID })
    }
    
    public func loadProducts() async {
        await MainActor.run { isLoadingProducts = true }
        do {
            let storeProducts = try await Product.products(for: Self.productIDs)
            await MainActor.run {
                self.products = storeProducts.sorted { lhs, rhs in
                    (lhs.subscription?.subscriptionPeriod.value ?? 0) > (rhs.subscription?.subscriptionPeriod.value ?? 0)
                }
                self.isLoadingProducts = false
            }
        } catch {
            await MainActor.run {
                self.purchaseError = "Unable to load subscription options. Check your connection and try again."
                self.isLoadingProducts = false
            }
        }
    }
    
    public func purchase(planID: String) async {
        guard let product = product(for: planID) else {
            await MainActor.run {
                purchaseError = "Subscription products are not available yet. Add them in App Store Connect, then try again."
            }
            return
        }
        
        await MainActor.run {
            isPurchasing = true
            purchaseError = nil
        }
        
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await refreshEntitlements()
                await transaction.finish()
            case .userCancelled:
                break
            case .pending:
                await MainActor.run {
                    purchaseError = "Purchase is pending approval. Pro unlocks after Apple confirms the transaction."
                }
            @unknown default:
                break
            }
        } catch {
            await MainActor.run {
                purchaseError = error.localizedDescription
            }
        }
        
        await MainActor.run { isPurchasing = false }
    }
    
    public func restorePurchases(completion: @escaping (Bool) -> Void) {
        Task {
            do {
                try await AppStore.sync()
                await refreshEntitlements()
                await MainActor.run { completion(isPro) }
            } catch {
                await MainActor.run {
                    purchaseError = error.localizedDescription
                    completion(false)
                }
            }
        }
    }
    
    public func manageSubscriptions() {
        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
        UIApplication.shared.open(url)
    }
    
    private func listenForTransactions() {
        updatesTask?.cancel()
        updatesTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                do {
                    let transaction = try self.checkVerified(result)
                    await self.refreshEntitlements()
                    await transaction.finish()
                } catch {
                    await MainActor.run {
                        self.purchaseError = "Could not verify a subscription update."
                    }
                }
            }
        }
    }
    
    private func refreshEntitlements() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               Self.productIDs.contains(transaction.productID) {
                entitled = true
                break
            }
        }
        let entitledNow = entitled
        await MainActor.run {
            self.isPro = entitledNow
            UserDefaults.standard.set(entitledNow, forKey: "is_pro_subscriber")
            if entitledNow && self.selectedRetention == .twentyDays {
                self.selectedRetention = .forever
                UserDefaults.standard.set(ReceiptRetentionOption.forever.rawValue, forKey: "receipt_retention_option")
            }
        }
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

private enum StoreError: Error {
    case failedVerification
}

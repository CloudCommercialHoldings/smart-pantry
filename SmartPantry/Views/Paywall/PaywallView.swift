import SwiftUI

public struct PaywallView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var subService = SubscriptionService.shared
    
    @State private var selectedPlanId: String = "annual"
    @State private var showLegal: LegalDocument? = nil
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                HStack {
                    Spacer()
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("Close")
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.accentColor, .green], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: "crown.fill")
                            .font(.system(size: 38))
                            .foregroundColor(.white)
                    }
                    
                    Text("Smart Pantry Pro")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                    
                    Text("Unlock unlimited receipts, tax reports, warranty tracking, and food photos.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                VStack(spacing: 14) {
                    planCard(
                        id: "annual",
                        title: "Annual Membership",
                        fallbackPrice: "$39.99 / year",
                        period: "Best value • billed yearly",
                        badge: "BEST VALUE",
                        trial: "3-day free trial"
                    )
                    planCard(
                        id: "monthly",
                        title: "Monthly Membership",
                        fallbackPrice: "$4.99 / month",
                        period: "Flexible month-to-month billing",
                        badge: nil,
                        trial: nil
                    )
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 14) {
                    Text("Included with Pro:")
                        .font(.headline)
                        .padding(.horizontal, 4)
                    
                    ProFeatureRow(icon: "doc.text.fill", color: .blue, title: "Unlimited Receipt Scanning", subtitle: "No 10-receipt cap for scanning and storing purchases")
                    ProFeatureRow(icon: "clock.arrow.circlepath", color: .purple, title: "Lifetime Receipt Retention", subtitle: "Keep receipts beyond the free 20-day window")
                    ProFeatureRow(icon: "square.and.arrow.up.fill", color: .orange, title: "Tax & Expense Reports", subtitle: "Export grocery spending by quarter or year")
                    ProFeatureRow(icon: "shield.checkerboard", color: .red, title: "Appliance Warranty Tracker", subtitle: "Track warranties, claim notes, and receipt proofs")
                    ProFeatureRow(icon: "camera.fill", color: .green, title: "Attach Food Pictures", subtitle: "Save photos directly on pantry items")
                    ProFeatureRow(icon: "magnifyingglass", color: .teal, title: "Advanced Search & History", subtitle: "Filter receipts by store, item, or date")
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(20)
                .padding(.horizontal)
                
                if let error = subService.purchaseError {
                    Text(error)
                        .font(.caption.weight(.medium))
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(spacing: 12) {
                    Button {
                        Task {
                            await subService.purchase(planID: selectedPlanId)
                            if subService.isPro {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    } label: {
                        HStack(spacing: 8) {
                            if subService.isPurchasing || subService.isLoadingProducts {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "applelogo")
                                    .font(.title3)
                            }
                            Text(subscribeButtonTitle)
                                .font(.headline.weight(.bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.accentColor)
                        .cornerRadius(16)
                    }
                    .disabled(subService.isPurchasing)
                    
                    Button("Restore Purchases") {
                        subService.restorePurchases { success in
                            if success {
                                presentationMode.wrappedValue.dismiss()
                            }
                        }
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                }
                .padding(.horizontal)
                
                VStack(spacing: 8) {
                    Text("Payment is charged to your Apple ID at confirmation. Subscriptions renew automatically unless canceled at least 24 hours before the end of the current period. Manage or cancel in iPhone Settings → Apple ID → Subscriptions.")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 16) {
                        Button("Privacy Policy") { showLegal = .privacy }
                        Button("Terms of Use") { showLegal = .terms }
                    }
                    .font(.caption.weight(.semibold))
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 24)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .task {
            await subService.loadProducts()
        }
        .sheet(item: $showLegal) { doc in
            NavigationView {
                LegalDocumentView(document: doc)
            }
        }
    }
    
    private var subscribeButtonTitle: String {
        if selectedPlanId == "annual" {
            return "Start 3-Day Free Trial"
        }
        return "Subscribe"
    }
    
    private func planCard(id: String, title: String, fallbackPrice: String, period: String, badge: String?, trial: String?) -> some View {
        let product = subService.product(for: id)
        let price = product?.displayPrice ?? fallbackPrice
        let plan = SubscriptionPlan(
            id: id,
            title: title,
            priceString: product == nil ? fallbackPrice : "\(price) / \(id == "annual" ? "year" : "month")",
            periodString: period,
            badge: badge,
            isPopular: id == "annual",
            trialDays: trial == nil ? nil : 3
        )
        return PaywallPlanCard(plan: plan, isSelected: selectedPlanId == id) {
            selectedPlanId = id
        }
    }
}

public struct PaywallPlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let action: () -> Void
    
    public init(plan: SubscriptionPlan, isSelected: Bool, action: @escaping () -> Void) {
        self.plan = plan
        self.isSelected = isSelected
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(plan.title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let badge = plan.badge {
                            Text(badge)
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange)
                                .cornerRadius(6)
                        }
                    }
                    
                    Text(plan.periodString)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(plan.priceString)
                        .font(.headline.weight(.bold))
                        .foregroundColor(.accentColor)
                    
                    if let trial = plan.trialDays {
                        Text("\(trial)-Day Free Trial")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.green)
                    }
                }
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .accentColor : .secondary)
                    .padding(.leading, 8)
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
    }
}

public struct ProFeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    public init(icon: String, color: Color, title: String, subtitle: String) {
        self.icon = icon
        self.color = color
        self.title = title
        self.subtitle = subtitle
    }
    
    public var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark")
                .font(.caption.weight(.bold))
                .foregroundColor(.green)
        }
    }
}

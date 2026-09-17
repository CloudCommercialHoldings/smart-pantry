import SwiftUI

public struct PaywallView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var subService = SubscriptionService.shared
    
    @State private var selectedPlanId: String = "annual"
    
    let plans: [SubscriptionPlan] = [
        SubscriptionPlan(
            id: "annual",
            title: "Annual Membership",
            priceString: "$39.99 / year",
            periodString: "Just $3.33 / month • Save 33%",
            badge: "BEST VALUE",
            isPopular: true,
            trialDays: 3
        ),
        SubscriptionPlan(
            id: "monthly",
            title: "Monthly Membership",
            priceString: "$4.99 / month",
            periodString: "Flexible month-to-month billing",
            badge: nil,
            isPopular: false,
            trialDays: nil
        )
    ]
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Close Button
                HStack {
                    Spacer()
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // Hero Banner
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
                    
                    Text("Unlock Unlimited Receipts, Tax Reports, Warranty Tracker & Food Photos")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                
                // Plans Toggle Cards
                VStack(spacing: 14) {
                    ForEach(plans) { plan in
                        PaywallPlanCard(
                            plan: plan,
                            isSelected: selectedPlanId == plan.id
                        ) {
                            selectedPlanId = plan.id
                        }
                    }
                }
                .padding(.horizontal)
                
                // Pro Features Checklist
                VStack(alignment: .leading, spacing: 14) {
                    Text("Included with Pro:")
                        .font(.headline)
                        .padding(.horizontal, 4)
                    
                    ProFeatureRow(icon: "doc.text.fill", color: .blue, title: "Unlimited Receipt Scanning", subtitle: "No 10-receipt cap for scanning & storing purchases")
                    ProFeatureRow(icon: "clock.arrow.circlepath", color: .purple, title: "Lifetime Receipt Retention", subtitle: "Never auto-remove receipts after 20 days")
                    ProFeatureRow(icon: "square.and.arrow.up.fill", color: .orange, title: "Tax & Expense Reports", subtitle: "Export grocery tax deductions by quarter or year")
                    ProFeatureRow(icon: "shield.checkerboard", color: .red, title: "Appliance Warranty Tracker", subtitle: "Track warranties, claim notes & receipt proofs")
                    ProFeatureRow(icon: "camera.fill", color: .green, title: "Attach Food Pictures", subtitle: "Snap & store actual food pictures directly to items")
                    ProFeatureRow(icon: "cloud.fill", color: .teal, title: "Cloud Backup & Advanced Search", subtitle: "Sync across devices & search by store, item, or date")
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(20)
                .padding(.horizontal)
                
                // Call To Action Buttons
                VStack(spacing: 12) {
                    // PayPal Option Button
                    Button {
                        subService.openPayPalCheckout()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "creditcard.circle.fill")
                                .font(.title3)
                            Text("Subscribe via PayPal")
                                .font(.headline.weight(.bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.0, green: 0.47, red: 0.8))
                        .cornerRadius(16)
                    }
                    
                    // App Store Free Trial / Subscribe Button
                    Button {
                        subService.activateProSubscription()
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "applelogo")
                                .font(.title3)
                            Text(selectedPlanId == "annual" ? "Start 3-Day Free Trial" : "Subscribe with Apple Pay")
                                .font(.headline.weight(.bold))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.accentColor)
                        .cornerRadius(16)
                    }
                    
                    // Restore Purchases
                    Button("Restore Purchases") {
                        subService.restorePurchases { _ in
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
                }
                .padding(.horizontal)
                
                // Footer legal text
                Text("Cancel anytime in Settings. Payment will be charged to your Apple ID / PayPal account at confirmation of purchase.")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 24)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
}

struct PaywallPlanCard: View {
    let plan: SubscriptionPlan
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
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

struct ProFeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    var body: some View {
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

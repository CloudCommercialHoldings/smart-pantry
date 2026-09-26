import SwiftUI

public struct PantryRewardsView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var gamification = GamificationService.shared
    @State private var showConfetti: Bool = false
    @State private var selectedGiftCardForDetails: GiftCardReward? = nil
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Current Level Header Card
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(gamification.currentLevel.badgeColor.opacity(0.18))
                                    .frame(width: 84, height: 84)
                                
                                Image(systemName: gamification.currentLevel.badgeIcon)
                                    .font(.system(size: 40))
                                    .foregroundColor(gamification.currentLevel.badgeColor)
                            }
                            .padding(.top, 8)
                            
                            Text(gamification.currentLevel.badgeTitle)
                                .font(.title.weight(.bold))
                                .foregroundColor(.primary)
                            
                            Text(gamification.currentLevel.criteriaDescription)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                            
                            // Progress to Master
                            VStack(spacing: 6) {
                                HStack {
                                    Text("Master Pantry Expert Progress")
                                        .font(.caption.weight(.semibold))
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("\(Int(gamification.progressToMaster * 100))%")
                                        .font(.caption.weight(.bold))
                                        .foregroundColor(gamification.currentLevel.badgeColor)
                                }
                                
                                GeometryReader { geo in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color(UIColor.tertiarySystemFill))
                                            .frame(height: 10)
                                        
                                        Capsule()
                                            .fill(LinearGradient(
                                                colors: [Color.green, Color.purple],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ))
                                            .frame(width: max(10, geo.size.width * gamification.progressToMaster), height: 10)
                                    }
                                }
                                .frame(height: 10)
                            }
                            .padding(.top, 8)
                        }
                        .padding(20)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // Gamification Stats Row
                        HStack(spacing: 12) {
                            StatBox(
                                title: "Weekly Scans",
                                value: "\(gamification.receiptsThisWeek)",
                                icon: "calendar.badge.clock",
                                color: .green
                            )
                            StatBox(
                                title: "Monthly Scans",
                                value: "\(gamification.receiptsThisMonth)",
                                icon: "doc.text.fill",
                                color: .blue
                            )
                            StatBox(
                                title: "Cleanups Done",
                                value: "\(gamification.pantryCleanupsCount)",
                                icon: "sparkles",
                                color: .purple
                            )
                        }
                        .padding(.horizontal)
                        
                        // Tier Breakdown Roadmap Card
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Pantry Tiers & Privileges")
                                .font(.headline)
                            
                            Divider()
                            
                            TierRow(
                                title: "Entry Pantry",
                                icon: "leaf.fill",
                                color: .green,
                                requirement: "Log receipts weekly (1+ receipts)",
                                isCurrent: gamification.currentLevel == .entry,
                                isUnlocked: true
                            )
                            
                            TierRow(
                                title: "Mid-Level Pantry",
                                icon: "star.fill",
                                color: .blue,
                                requirement: "Log receipts monthly (3+ receipts)",
                                isCurrent: gamification.currentLevel == .midLevel,
                                isUnlocked: gamification.totalReceiptsLogged >= 3
                            )
                            
                            TierRow(
                                title: "Master Pantry Expert",
                                icon: "crown.fill",
                                color: .purple,
                                requirement: "Monthly receipts + pantry cleanups (5+ receipts & 3+ cleanups)",
                                isCurrent: gamification.currentLevel == .master,
                                isUnlocked: gamification.isMasterUnlocked
                            )
                        }
                        .padding(18)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // Gift Cards Vault Section
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                Image(systemName: "gift.fill")
                                    .foregroundColor(.purple)
                                Text("Achievement Rewards")
                                    .font(.headline)
                                Spacer()
                                if gamification.isMasterUnlocked {
                                    Text("UNLOCKED")
                                        .font(.caption2.weight(.bold))
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 3)
                                        .background(Color.purple.opacity(0.15))
                                        .foregroundColor(.purple)
                                        .cornerRadius(6)
                                } else {
                                    Label("Master Only", systemImage: "lock.fill")
                                        .font(.caption2.weight(.bold))
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Text(gamification.isMasterUnlocked
                                 ? "You unlocked in-app pantry badges for staying on top of receipts and cleanups. These are achievements only — not retailer gift cards."
                                 : "Reach Master Pantry Expert by logging receipts and cleaning up expired items to unlock in-app achievement badges.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            ForEach(gamification.availableGiftCards) { card in
                                GiftCardRow(
                                    card: card,
                                    isUnlocked: gamification.isMasterUnlocked,
                                    onClaim: {
                                        gamification.claimGiftCard(card)
                                        showConfetti = true
                                    }
                                )
                            }
                            
                            if !gamification.claimedGiftCards.isEmpty {
                                Text("Claimed Badges")
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.secondary)
                                    .padding(.top, 8)
                                
                                ForEach(gamification.claimedGiftCards) { card in
                                    ClaimedCardRow(card: card)
                                }
                            }
                        }
                        .padding(18)
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // Celebration Confetti Button
                        Button {
                            showConfetti = true
                        } label: {
                            Label("Celebrate Milestones 🎉", systemImage: "sparkles")
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.purple)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.purple.opacity(0.12))
                                .cornerRadius(14)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    }
                    .padding(.top)
                }
                
                // Falling Confetti Layer
                ConfettiView(isActive: $showConfetti)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Pantry Gamification")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                if gamification.isMasterUnlocked {
                    showConfetti = true
                }
            }
        }
    }
}

struct StatBox: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.headline)
            Text(value)
                .font(.title2.weight(.bold))
                .foregroundColor(.primary)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(14)
    }
}

struct TierRow: View {
    let title: String
    let icon: String
    let color: Color
    let requirement: String
    let isCurrent: Bool
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? color.opacity(0.15) : Color(UIColor.tertiarySystemFill))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(isUnlocked ? color : .secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                    if isCurrent {
                        Text("CURRENT")
                            .font(.caption2.weight(.bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(color.opacity(0.15))
                            .foregroundColor(color)
                            .cornerRadius(6)
                    }
                }
                Text(requirement)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct GiftCardRow: View {
    let card: GiftCardReward
    let isUnlocked: Bool
    let onClaim: () -> Void
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.purple.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: card.iconName)
                    .font(.title3)
                    .foregroundColor(.purple)
            }
            
            VStack(alignment: .leading, spacing: 3) {
                Text("\(card.storeName)")
                    .font(.subheadline.weight(.bold))
                Text(card.expiryNotice)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isUnlocked {
                Button {
                    onClaim()
                } label: {
                    Text("Claim")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.purple)
                        .cornerRadius(8)
                }
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(Color(UIColor.tertiarySystemGroupedBackground))
        .cornerRadius(14)
    }
}

struct ClaimedCardRow: View {
    let card: GiftCardReward
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(card.storeName)
                    .font(.subheadline.weight(.bold))
                Spacer()
                Text(card.amount)
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.green)
            }
            
            HStack {
                Text("Badge:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(card.code)
                    .font(.system(.caption, design: .monospaced).weight(.bold))
                    .foregroundColor(.primary)
                Spacer()
                Text("CLAIMED")
                    .font(.caption2.weight(.bold))
                    .foregroundColor(.green)
            }
        }
        .padding(12)
        .background(Color.green.opacity(0.08))
        .cornerRadius(12)
    }
}

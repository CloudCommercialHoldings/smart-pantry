import SwiftUI

public struct SpendingAnalyticsView: View {
    @StateObject var viewModel = AnalyticsViewModel()
    @ObservedObject var subService = SubscriptionService.shared
    @State private var showPaywall: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Pro Tools Navigation Cards
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Pro Tools & Reports")
                            .font(.headline)
                        
                        NavigationLink(destination: WarrantyTrackerView()) {
                            ProToolCard(
                                icon: "shield.checkerboard",
                                title: "Warranty Tracker",
                                subtitle: "Track appliance warranties & claim notes",
                                color: .red,
                                isProLocked: !subService.isPro
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        NavigationLink(destination: TaxReportView()) {
                            ProToolCard(
                                icon: "square.and.arrow.up.fill",
                                title: "Tax & Expense Reports",
                                subtitle: "Export deductible grocery tax summaries",
                                color: .orange,
                                isProLocked: !subService.isPro
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Overall Stats Summary Cards
                    HStack(spacing: 12) {
                        StatMetricCard(
                            title: "Total Spent",
                            value: String(format: "$%.2f", viewModel.totalGrocerySpend),
                            subtitle: "\(viewModel.totalReceiptsCount) receipts",
                            icon: "creditcard.fill",
                            color: .accentColor
                        )
                        
                        StatMetricCard(
                            title: "Avg / Trip",
                            value: String(format: "$%.2f", viewModel.averageTripSpend),
                            subtitle: "Per grocery trip",
                            icon: "cart.fill",
                            color: .purple
                        )
                    }
                    .padding(.horizontal)
                    
                    // Food Waste Prevention Metrics Card
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "leaf.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                            Text("Food Waste Savings")
                                .font(.headline)
                            Spacer()
                            Text("\(viewModel.foodWasteSavedPercentage, specifier: "%.0f")% Saved")
                                .font(.subheadline.weight(.bold))
                                .foregroundColor(.green)
                        }
                        
                        Divider()
                        
                        HStack(spacing: 16) {
                            WasteMetricItem(title: "Active Inventory", value: "\(viewModel.activePantryItemCount) items", subValue: String(format: "$%.2f est.", viewModel.activePantryEstimatedValue))
                            WasteMetricItem(title: "Items Consumed", value: "\(viewModel.consumedItemCount) items", subValue: "Zero Waste")
                            WasteMetricItem(title: "Items Expired", value: "\(viewModel.expiredItemCount) items", subValue: "Spoiled")
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    // Category Breakdown Chart
                    if !viewModel.categoryBreakdown.isEmpty {
                        CategoryBreakdownChart(categories: viewModel.categoryBreakdown)
                            .padding(.horizontal)
                    }
                    
                    // Monthly Trends
                    if !viewModel.monthlyTrends.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Monthly Spending History")
                                .font(.headline)
                            
                            ForEach(viewModel.monthlyTrends) { trend in
                                HStack {
                                    Text(trend.monthYear)
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text("\(trend.receiptCount) trips")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("$\(trend.totalSpent, specifier: "%.2f")")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundColor(.accentColor)
                                        .frame(width: 80, alignment: .trailing)
                                }
                                Divider()
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Analytics & Reports")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

public struct ProToolCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let isProLocked: Bool
    
    public init(icon: String, title: String, subtitle: String, color: Color, isProLocked: Bool) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.color = color
        self.isProLocked = isProLocked
    }
    
    public var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if isProLocked {
                        Text("PRO")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange)
                            .cornerRadius(6)
                    }
                }
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.secondary)
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

public struct StatMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    public init(title: String, value: String, subtitle: String, icon: String, color: Color) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

public struct WasteMetricItem: View {
    let title: String
    let value: String
    let subValue: String
    
    public init(title: String, value: String, subValue: String) {
        self.title = title
        self.value = value
        self.subValue = subValue
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline.weight(.bold))
            Text(subValue)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

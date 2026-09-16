import SwiftUI

public struct SpendingAnalyticsView: View {
    @StateObject var viewModel = AnalyticsViewModel()
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
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
                    .padding(.top, 8)
                    
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
                    
                    // Top Stores Leaderboard
                    if !viewModel.storeLeaderboard.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Top Grocery Stores")
                                .font(.headline)
                            
                            ForEach(Array(viewModel.storeLeaderboard.prefix(5))) { store in
                                HStack {
                                    Image(systemName: "building.2.fill")
                                        .foregroundColor(.accentColor)
                                    Text(store.storeName)
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text("\(store.visitCount) visits")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("$\(store.totalSpent, specifier: "%.2f")")
                                        .font(.subheadline.weight(.bold))
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
            .navigationTitle("Spending & Analytics")
        }
    }
}

struct StatMetricCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
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

struct WasteMetricItem: View {
    let title: String
    let value: String
    let subValue: String
    
    var body: some View {
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

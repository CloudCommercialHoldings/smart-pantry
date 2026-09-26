import SwiftUI

public struct FDAFactsView: View {
    @Environment(\.presentationMode) var presentationMode
    let item: PantryItem
    let shelfLifeInfo: FoodShelfLifeInfo
    
    public init(item: PantryItem) {
        self.item = item
        let result = FoodShelfLifeAPIService.shared.estimateShelfLife(
            itemName: item.name,
            location: item.location,
            purchaseDate: item.purchaseDate
        )
        self.shelfLifeInfo = result.info
    }
    
    public var daysSincePurchase: Int {
        let calendar = Calendar.current
        let startOfPurchase = calendar.startOfDay(for: item.purchaseDate)
        let startOfToday = calendar.startOfDay(for: Date())
        let components = calendar.dateComponents([.day], from: startOfPurchase, to: startOfToday)
        return max(components.day ?? 0, 0)
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header Status Card
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(item.location.themeColor.opacity(0.15))
                                .frame(width: 72, height: 72)
                            
                            Image(systemName: item.location.iconName)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(item.location.themeColor)
                        }
                        .padding(.top, 8)
                        
                        Text(item.name)
                            .font(.title2.weight(.bold))
                        
                        HStack(spacing: 10) {
                            Label(item.location.rawValue, systemImage: item.location.iconName)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(item.location.themeColor.opacity(0.15))
                                .foregroundColor(item.location.themeColor)
                                .cornerRadius(8)
                            
                            Text("Stored for \(daysSincePurchase) days")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Freezer-specific banner if applicable
                    if item.location == .freezer {
                        HStack(spacing: 12) {
                            Image(systemName: "snowflake")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Freezer Extends Shelf Life")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundColor(.blue)
                                Text("In freezer for \(daysSincePurchase) days. Freezing at 0°F preserves food safely almost indefinitely; quality & texture peak within recommended months.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    // Spice Rack specific banner if applicable
                    if item.location == .spiceRack {
                        HStack(spacing: 12) {
                            Image(systemName: "flame.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Spice Rack Freshness & Anti-Hardening")
                                    .font(.subheadline.weight(.bold))
                                    .foregroundColor(.orange)
                                Text("Stored for \(daysSincePurchase) days. Steam from cooking causes spices to clump and harden. Never shake directly over hot steaming pots.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                    
                    // Official FDA Facts Card
                    VStack(alignment: .leading, spacing: 14) {
                        HStack {
                            Image(systemName: "shield.lefthalf.filled")
                                .foregroundColor(.accentColor)
                            Text("Official FDA / USDA FoodKeeper Facts")
                                .font(.headline)
                        }
                        
                        Divider()
                        
                        Text(shelfLifeInfo.fdaFacts)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                        
                        if let freezerAdvice = shelfLifeInfo.freezerGuidance, item.location == .freezer {
                            Divider()
                            Text(freezerAdvice)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                                .lineSpacing(4)
                        }
                        
                        if let spiceAdvice = shelfLifeInfo.spiceGuidance, item.location == .spiceRack {
                            Divider()
                            Text(spiceAdvice)
                                .font(.subheadline)
                                .foregroundColor(.orange)
                                .lineSpacing(4)
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    // Shelf Life Benchmark Reference Card
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recommended Storage Benchmarks")
                            .font(.headline)
                        
                        HStack {
                            BenchmarkItem(title: "Refrigerator", days: "\(shelfLifeInfo.fridgeDays)d", icon: "refrigerator", color: .cyan)
                            Spacer()
                            BenchmarkItem(title: "Freezer", days: "\(shelfLifeInfo.freezerDays)d", icon: "snowflake", color: .blue)
                            Spacer()
                            BenchmarkItem(title: "Pantry", days: "\(shelfLifeInfo.pantryDays)d", icon: "cabinet.fill", color: .orange)
                            if let sDays = shelfLifeInfo.spiceRackDays {
                                Spacer()
                                BenchmarkItem(title: "Spice Rack", days: "\(sDays)d", icon: "flame.fill", color: .red)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(20)
                    .padding(.horizontal)
                    
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Text("Got It")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .cornerRadius(14)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
                .padding(.top)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("FDA Food Facts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct BenchmarkItem: View {
    let title: String
    let days: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundColor(color)
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            Text(days)
                .font(.caption.weight(.bold))
                .foregroundColor(.primary)
        }
        .frame(minWidth: 64)
        .padding(.vertical, 8)
        .padding(.horizontal, 6)
        .background(color.opacity(0.1))
        .cornerRadius(10)
    }
}

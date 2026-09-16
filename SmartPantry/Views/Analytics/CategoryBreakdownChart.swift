import SwiftUI

public struct CategoryBreakdownChart: View {
    let categories: [CategorySpending]
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Category Breakdown")
                .font(.headline)
            
            // Stacked Multi-Color Progress Bar
            GeometryReader { geometry in
                HStack(spacing: 2) {
                    ForEach(categories) { item in
                        Rectangle()
                            .fill(item.category.categoryColor)
                            .frame(width: max(geometry.size.width * CGFloat(item.percentage / 100.0), 4))
                    }
                }
                .cornerRadius(6)
            }
            .frame(height: 14)
            
            // Legend & Detailed List
            VStack(spacing: 10) {
                ForEach(categories) { item in
                    HStack {
                        Circle()
                            .fill(item.category.categoryColor)
                            .frame(width: 10, height: 10)
                        
                        Text(item.category.rawValue)
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text("\(item.percentage, specifier: "%.1f")%")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                        
                        Text("$\(item.totalSpent, specifier: "%.2f")")
                            .font(.subheadline.weight(.bold))
                            .frame(width: 70, alignment: .trailing)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

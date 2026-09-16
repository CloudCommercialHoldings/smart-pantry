import SwiftUI

public struct PantryItemRowView: View {
    let item: PantryItem
    let onConsume: () -> Void
    let onExtend: () -> Void
    
    public var body: some View {
        HStack(spacing: 14) {
            // Category Icon Badge
            ZStack {
                Circle()
                    .fill(item.category.categoryColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                
                Image(systemName: item.category.iconName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(item.category.categoryColor)
            }
            
            // Name & Subtitle Info
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(item.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if item.quantity > 1 {
                        Text("\(formattedQty(item.quantity)) \(item.unit)")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.12))
                            .cornerRadius(6)
                    }
                }
                
                HStack(spacing: 10) {
                    // Location Pill
                    Label(item.location.rawValue, systemImage: item.location.iconName)
                        .font(.caption)
                        .foregroundColor(item.location.themeColor)
                    
                    if let price = item.purchasePrice {
                        Text("•  $\(price, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Expiry Status Badge
            VStack(alignment: .trailing, spacing: 4) {
                Text(expiryLabelText(item))
                    .font(.caption.weight(.bold))
                    .foregroundColor(item.expiryStatus.badgeColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(item.expiryStatus.badgeColor.opacity(0.15))
                    .cornerRadius(8)
                
                Text(formattedDate(item.expirationDate))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                onConsume()
            } label: {
                Label("Consume", systemImage: "checkmark.circle.fill")
            }
            .tint(.green)
            
            Button {
                onExtend()
            } label: {
                Label("+3 Days", systemImage: "calendar.badge.clock")
            }
            .tint(.blue)
        }
    }
    
    private func formattedQty(_ qty: Double) -> String {
        qty.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", qty) : String(format: "%.1f", qty)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func expiryLabelText(_ item: PantryItem) -> String {
        let days = item.daysUntilExpiration
        if days < 0 {
            return "Expired (\(abs(days))d)"
        } else if days == 0 {
            return "Expires Today"
        } else if days == 1 {
            return "1 Day Left"
        } else {
            return "\(days) Days Left"
        }
    }
}

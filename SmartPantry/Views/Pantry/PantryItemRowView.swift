import SwiftUI

public struct PantryItemRowView: View {
    let item: PantryItem
    let onConsume: () -> Void
    let onExtend: () -> Void
    
    public var body: some View {
        HStack(spacing: 16) {
            // Food Image Thumbnail or Category Icon Badge
            if let imgData = item.itemImageData, let uiImage = UIImage(data: imgData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(item.category.categoryColor.opacity(0.15))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: item.category.iconName)
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(item.category.categoryColor)
                }
            }
            
            // Name & Subtitle Info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(item.name)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    if item.quantity > 1 {
                        Text("\(formattedQty(item.quantity)) \(item.unit)")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color(UIColor.tertiarySystemFill))
                            .cornerRadius(8)
                    }
                }
                
                HStack(spacing: 8) {
                    // Location Pill
                    Label(item.location.rawValue, systemImage: item.location.iconName)
                        .font(.caption.weight(.medium))
                        .foregroundColor(item.location.themeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(item.location.themeColor.opacity(0.12))
                        .cornerRadius(6)
                    
                    if let price = item.purchasePrice {
                        Text("$\(price, specifier: "%.2f")")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer(minLength: 4)
            
            // Expiry Status Badge
            VStack(alignment: .trailing, spacing: 4) {
                Text(expiryLabelText(item))
                    .font(.caption.weight(.bold))
                    .foregroundColor(item.expiryStatus.badgeColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(item.expiryStatus.badgeColor.opacity(0.15))
                    .cornerRadius(10)
                
                Text(formattedDate(item.expirationDate))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
        .padding(.vertical, 4)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive) {
                onConsume()
            } label: {
                Label("Consumed", systemImage: "checkmark.circle.fill")
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

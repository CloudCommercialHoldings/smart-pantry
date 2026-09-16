import SwiftUI

public struct ReceiptDetailView: View {
    @ObservedObject var viewModel: ReceiptHistoryViewModel
    @State var receipt: ReceiptRecord
    @State private var showRawText: Bool = false
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Card
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(receipt.storeName)
                                .font(.title2.weight(.bold))
                            Text(receipt.purchaseDate, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Total Paid")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("$\(receipt.totalAmount, specifier: "%.2f")")
                                .font(.title.weight(.bold))
                                .foregroundColor(.accentColor)
                        }
                    }
                    
                    Divider()
                    
                    HStack {
                        Label("Payment: \(receipt.paymentMethod)", systemImage: "creditcard.fill")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("Subtotal: $\(receipt.subtotal, specifier: "%.2f") • Tax: $\(receipt.tax, specifier: "%.2f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                
                // Receipt Image Thumbnail Preview if available
                if let data = receipt.receiptImageData, let uiImage = UIImage(data: data) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Scanned Receipt Image")
                            .font(.headline)
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 240)
                            .cornerRadius(12)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                }
                
                // Item Breakdown Section
                VStack(alignment: .leading, spacing: 14) {
                    Text("Purchased Items (\(receipt.items.count))")
                        .font(.headline)
                    
                    ForEach(receipt.items) { item in
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(item.category.categoryColor.opacity(0.12))
                                    .frame(width: 36, height: 36)
                                Image(systemName: item.category.iconName)
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(item.category.categoryColor)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.normalizedName)
                                    .font(.subheadline.weight(.semibold))
                                Text("\(item.category.rawValue) • Qty: \(item.quantity, specifier: "%.1f")")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("$\(item.totalPrice, specifier: "%.2f")")
                                .font(.subheadline.weight(.bold))
                        }
                        Divider()
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                
                // Raw OCR Text Expander
                DisclosureGroup("View Raw OCR Text", isExpanded: $showRawText) {
                    Text(receipt.rawText.isEmpty ? "No raw text recorded." : receipt.rawText)
                        .font(.system(.caption, design: .monospaced))
                        .padding(8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.tertiarySystemGroupedBackground))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(receipt.storeName)
        .navigationBarTitleDisplayMode(.inline)
    }
}

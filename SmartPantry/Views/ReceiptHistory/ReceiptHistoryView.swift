import SwiftUI

public struct ReceiptHistoryView: View {
    @StateObject var viewModel = ReceiptHistoryViewModel()
    @State private var showFilterSheet: Bool = false
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Total Spend Header Card
                VStack(spacing: 8) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Total Spending (\(viewModel.selectedDateRange.rawValue))")
                                .font(.caption.weight(.medium))
                                .foregroundColor(.secondary)
                            
                            Text("$\(viewModel.totalSpentInFiltered, specifier: "%.2f")")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.accentColor)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Avg / Trip")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("$\(viewModel.averageSpendPerReceipt, specifier: "%.2f")")
                                .font(.headline.weight(.bold))
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                .padding(.top, 8)
                
                // Receipts List
                if viewModel.filteredReceipts.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        Text("No Receipts Found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Scanned shopping receipts will appear here with spending analytics.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(viewModel.filteredReceipts) { receipt in
                            NavigationLink(destination: ReceiptDetailView(viewModel: viewModel, receipt: receipt)) {
                                ReceiptHistoryRow(receipt: receipt)
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                let receipt = viewModel.filteredReceipts[index]
                                viewModel.deleteReceipt(receipt)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Receipt History")
            .searchable(text: $viewModel.searchText, prompt: "Search store or items...")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showFilterSheet = true
                    } label: {
                        Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                ReceiptFilterView(viewModel: viewModel)
            }
        }
    }
}

struct ReceiptHistoryRow: View {
    let receipt: ReceiptRecord
    
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 46, height: 46)
                
                Image(systemName: "cart.fill")
                    .font(.title3)
                    .foregroundColor(.accentColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(receipt.storeName)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    Text(receipt.purchaseDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("• \(receipt.itemCount) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(receipt.totalAmount, specifier: "%.2f")")
                    .font(.headline.weight(.bold))
                    .foregroundColor(.primary)
                
                Text(receipt.paymentMethod)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

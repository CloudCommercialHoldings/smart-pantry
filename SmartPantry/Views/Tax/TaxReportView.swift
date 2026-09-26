import SwiftUI

public struct TaxReportView: View {
    @ObservedObject var storage = StorageService.shared
    @ObservedObject var subService = SubscriptionService.shared
    
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var showPaywall: Bool = false
    @State private var exportItems: [Any] = []
    @State private var showShareSheet: Bool = false
    
    private var yearReceipts: [ReceiptRecord] {
        storage.receipts.filter {
            Calendar.current.component(.year, from: $0.purchaseDate) == selectedYear
        }
    }
    
    public var totalTaxPaid: Double {
        yearReceipts.reduce(0.0) { $0 + $1.tax }
    }
    
    public var totalEligibleDeductions: Double {
        yearReceipts.reduce(0.0) { $0 + $1.totalAmount }
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                VStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    
                    Text("Tax & Expense Reports")
                        .font(.title2.weight(.bold))
                    
                    Text("Export a personal grocery spending summary. This is not tax, legal, or accounting advice.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 16)
                
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Sales Tax Recorded")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(totalTaxPaid, specifier: "%.2f")")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.orange)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Gross Receipts")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("$\(totalEligibleDeductions, specifier: "%.2f")")
                            .font(.title2.weight(.bold))
                            .foregroundColor(.accentColor)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemGroupedBackground))
                    .cornerRadius(16)
                }
                .padding(.horizontal)
                
                Picker("Tax Year", selection: $selectedYear) {
                    Text("2026").tag(2026)
                    Text("2025").tag(2025)
                    Text("2024").tag(2024)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                Text("\(yearReceipts.count) receipts in \(String(selectedYear))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button {
                    if subService.isPro {
                        shareCSV()
                    } else {
                        showPaywall = true
                    }
                } label: {
                    HStack {
                        Image(systemName: "square.and.arrow.up.fill")
                        Text(subService.isPro ? "Share CSV Summary" : "Unlock CSV Export (Pro)")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(14)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Tax Reports")
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityShareView(items: exportItems)
        }
    }
    
    private func shareCSV() {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        var lines = ["Store,Date,Subtotal,Tax,Total,Item Count"]
        for receipt in yearReceipts.sorted(by: { $0.purchaseDate < $1.purchaseDate }) {
            let store = receipt.storeName.replacingOccurrences(of: "\"", with: "\"\"")
            lines.append("\"\(store)\",\(formatter.string(from: receipt.purchaseDate)),\(String(format: "%.2f", receipt.subtotal)),\(String(format: "%.2f", receipt.tax)),\(String(format: "%.2f", receipt.totalAmount)),\(receipt.itemCount)")
        }
        lines.append("")
        lines.append("Totals,,,\(String(format: "%.2f", totalTaxPaid)),\(String(format: "%.2f", totalEligibleDeductions)),")
        let csv = lines.joined(separator: "\n")
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("SmartPantry-Spending-\(selectedYear).csv")
        do {
            try csv.data(using: .utf8)?.write(to: url)
            exportItems = [url]
            showShareSheet = true
        } catch {
            exportItems = [csv]
            showShareSheet = true
        }
    }
}

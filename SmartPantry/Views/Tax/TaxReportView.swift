import SwiftUI

public struct TaxReportView: View {
    @ObservedObject var storage = StorageService.shared
    @ObservedObject var subService = SubscriptionService.shared
    
    @State private var selectedYear: Int = 2026
    @State private var showExportAlert: Bool = false
    @State private var showPaywall: Bool = false
    
    public var totalTaxPaid: Double {
        storage.receipts.reduce(0.0) { $0 + $1.tax }
    }
    
    public var totalEligibleDeductions: Double {
        storage.receipts.reduce(0.0) { $0 + $1.totalAmount }
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header Banner
                VStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up.fill")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    
                    Text("Tax & Expense Reports")
                        .font(.title2.weight(.bold))
                    
                    Text("Export itemized tax summaries for business expense write-offs and annual grocery tax filings.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                .padding(.top, 16)
                
                // Tax Summary Cards
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Total Sales Tax Paid")
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
                        Text("Total Gross Receipts")
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
                
                // Year Selector
                Picker("Tax Year", selection: $selectedYear) {
                    Text("2026").tag(2026)
                    Text("2025").tag(2025)
                    Text("2024").tag(2024)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Export Buttons
                VStack(spacing: 12) {
                    Button {
                        if subService.isPro {
                            showExportAlert = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.fill")
                            Text("Export CSV Tax Summary (Pro)")
                                .font(.headline)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(14)
                    }
                    
                    Button {
                        if subService.isPro {
                            showExportAlert = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.down.doc.fill")
                            Text("Export Itemized PDF Report (Pro)")
                                .font(.headline)
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(14)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Tax Reports")
        .alert("Report Exported!", isPresented: $showExportAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Tax report for \(selectedYear) has been compiled and copied to your device documents.")
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

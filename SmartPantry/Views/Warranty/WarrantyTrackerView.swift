import SwiftUI

public struct WarrantyTrackerView: View {
    @ObservedObject var storage = StorageService.shared
    @ObservedObject var subService = SubscriptionService.shared
    
    @State private var searchText: String = ""
    @State private var showAddWarranty: Bool = false
    @State private var showPaywall: Bool = false
    
    public var filteredWarranties: [WarrantyItem] {
        if searchText.isEmpty {
            return storage.warranties.sorted(by: { $0.expirationDate < $1.expirationDate })
        }
        let q = searchText.lowercased()
        return storage.warranties.filter {
            $0.title.lowercased().contains(q) || $0.storeName.lowercased().contains(q)
        }.sorted(by: { $0.expirationDate < $1.expirationDate })
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if storage.warranties.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "shield.checkerboard")
                        .font(.system(size: 56))
                        .foregroundColor(.accentColor)
                    
                    Text("No Appliance Warranties Tracked")
                        .font(.title2.weight(.bold))
                    
                    Text("Log kitchen appliances, hardware, and high-value purchases with warranty expiration dates and proof of purchase.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    Button {
                        if subService.isPro {
                            showAddWarranty = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Label("Add Warranty (Pro)", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.top, 8)
                    
                    Spacer()
                }
            } else {
                List {
                    ForEach(filteredWarranties) { item in
                        WarrantyCardRow(item: item)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let item = filteredWarranties[index]
                            storage.deleteWarranty(item)
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Warranty Tracker")
        .searchable(text: $searchText, prompt: "Search appliance or store...")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if subService.isPro {
                        showAddWarranty = true
                    } else {
                        showPaywall = true
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
            }
        }
        .sheet(isPresented: $showAddWarranty) {
            AddWarrantyView()
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

struct WarrantyCardRow: View {
    let item: WarrantyItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(item.statusBadgeColor.opacity(0.12))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "shield.fill")
                        .font(.title3)
                        .foregroundColor(item.statusBadgeColor)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Purchased at \(item.storeName)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(item.isExpired ? "Expired" : "\(item.daysUntilWarrantyExpiration)d Left")
                        .font(.caption.weight(.bold))
                        .foregroundColor(item.statusBadgeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(item.statusBadgeColor.opacity(0.15))
                        .cornerRadius(8)
                    
                    Text(item.expirationDate, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            if let notes = item.claimNotes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                    .cornerRadius(8)
            }
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.vertical, 4)
    }
}

import SwiftUI

public struct AddWarrantyView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var subService = SubscriptionService.shared
    
    @State private var title: String = ""
    @State private var storeName: String = "Target"
    @State private var purchaseDate: Date = Date()
    @State private var warrantyMonths: Int = 12
    @State private var claimNotes: String = ""
    @State private var hasConfirmedBoxNotice: Bool = false
    @State private var showPaywall: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            Form {
                // Mandatory Notice Banner with Asterisk
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("* Notice")
                                .font(.headline)
                                .foregroundColor(.orange)
                        }
                        
                        Text("\"Warranty period should be on your box\"*")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.primary)
                        
                        Text("Check the original product packaging, manual, or barcode sticker for the manufacturer warranty duration.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                
                Section(header: Text("Appliance / Item Info")) {
                    TextField("Product Title (e.g. Ninja Blender, Espresso Machine)", text: $title)
                    TextField("Store Name", text: $storeName)
                }
                
                Section(header: Text("Warranty Duration")) {
                    DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)
                    Stepper("Warranty Period: \(warrantyMonths) Months", value: $warrantyMonths, in: 1...120, step: 6)
                    
                    HStack {
                        Text("Warranty Expiration")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(calculatedExpirationDate, style: .date)
                            .fontWeight(.semibold)
                    }
                }
                
                Section(header: Text("Claim Notes & Model Info")) {
                    TextField("Serial #, Model #, Support Phone...", text: $claimNotes)
                }
                
                // Mandatory Verification Toggle
                Section(header: Text("Required Verification *"), footer: Text("You must verify the warranty period from your packaging before saving to your warranty vault.")) {
                    Toggle(isOn: $hasConfirmedBoxNotice) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("I confirmed warranty period on box *")
                                .font(.subheadline.weight(.semibold))
                            Text("Verified from manufacturer packaging")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Add Warranty (Pro)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if !subService.isPro {
                            showPaywall = true
                        } else {
                            saveWarranty()
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty || !hasConfirmedBoxNotice)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .onAppear {
                if !subService.isPro {
                    showPaywall = true
                }
            }
        }
    }
    
    private var calculatedExpirationDate: Date {
        Calendar.current.date(byAdding: .month, value: warrantyMonths, to: purchaseDate) ?? Date()
    }
    
    private func saveWarranty() {
        let warranty = WarrantyItem(
            title: title.trimmingCharacters(in: .whitespaces),
            storeName: storeName.trimmingCharacters(in: .whitespaces),
            purchaseDate: purchaseDate,
            warrantyMonths: warrantyMonths,
            claimNotes: claimNotes.isEmpty ? nil : claimNotes
        )
        StorageService.shared.addWarranty(warranty)
    }
}

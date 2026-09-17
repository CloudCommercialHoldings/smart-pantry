import SwiftUI

public struct AddWarrantyView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var title: String = ""
    @State private var storeName: String = "Target"
    @State private var purchaseDate: Date = Date()
    @State private var warrantyMonths: Int = 12
    @State private var claimNotes: String = ""
    
    public var body: some View {
        NavigationView {
            Form {
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
                            .weight(.semibold)
                    }
                }
                
                Section(header: Text("Claim Notes & Model Info")) {
                    TextField("Serial #, Model #, Support Phone...", text: $claimNotes)
                }
            }
            .navigationTitle("Add Warranty")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWarranty()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
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

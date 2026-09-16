import SwiftUI

public struct AddEditItemView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: PantryViewModel
    var itemToEdit: PantryItem?
    
    @State private var name: String = ""
    @State private var category: ItemCategory = .produce
    @State private var location: StorageLocation = .fridge
    @State private var quantity: Double = 1.0
    @State private var unit: String = "pcs"
    @State private var priceString: String = ""
    @State private var purchaseDate: Date = Date()
    @State private var expirationDate: Date = Date()
    @State private var notes: String = ""
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Information")) {
                    TextField("Item Name (e.g. Milk, Bananas, Chicken)", text: $name)
                        .onChange(of: name) { newName in
                            if itemToEdit == nil && !newName.isEmpty {
                                autoPredictExpiry(for: newName)
                            }
                        }
                    
                    Picker("Category", selection: $category) {
                        ForEach(ItemCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.iconName)
                                .tag(cat)
                        }
                    }
                    
                    Picker("Storage Location", selection: $location) {
                        ForEach(StorageLocation.allCases) { loc in
                            Label(loc.rawValue, systemImage: loc.iconName)
                                .tag(loc)
                        }
                    }
                    .onChange(of: location) { newLoc in
                        if itemToEdit == nil {
                            autoPredictExpiry(for: name, forceLocation: newLoc)
                        }
                    }
                }
                
                Section(header: Text("Quantity & Price")) {
                    HStack {
                        Text("Quantity")
                        Spacer()
                        TextField("Qty", value: $quantity, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                        
                        TextField("Unit", text: $unit)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 50)
                    }
                    
                    HStack {
                        Text("Purchase Price ($)")
                        Spacer()
                        TextField("0.00", text: $priceString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
                
                Section(header: Text("Dates")) {
                    DatePicker("Purchase Date", selection: $purchaseDate, displayedComponents: .date)
                    DatePicker("Expiration Date", selection: $expirationDate, displayedComponents: .date)
                }
                
                Section(header: Text("Notes")) {
                    TextField("Optional notes...", text: $notes)
                }
            }
            .navigationTitle(itemToEdit == nil ? "Add Pantry Item" : "Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveItem()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let item = itemToEdit {
                    self.name = item.name
                    self.category = item.category
                    self.location = item.location
                    self.quantity = item.quantity
                    self.unit = item.unit
                    if let p = item.purchasePrice {
                        self.priceString = String(format: "%.2f", p)
                    }
                    self.purchaseDate = item.purchaseDate
                    self.expirationDate = item.expirationDate
                    self.notes = item.notes ?? ""
                }
            }
        }
    }
    
    private func autoPredictExpiry(for itemName: String, forceLocation: StorageLocation? = nil) {
        let predicted = ExpiryDatabaseService.shared.predictMetadata(itemName: itemName, location: forceLocation)
        self.category = predicted.category
        if forceLocation == nil {
            self.location = predicted.location
        }
        self.expirationDate = predicted.expirationDate
    }
    
    private func saveItem() {
        let price = Double(priceString)
        let cleanName = name.trimmingCharacters(in: .whitespaces)
        
        if var existing = itemToEdit {
            existing.name = cleanName
            existing.category = category
            existing.location = location
            existing.quantity = quantity
            existing.unit = unit
            existing.purchasePrice = price
            existing.purchaseDate = purchaseDate
            existing.expirationDate = expirationDate
            existing.notes = notes.isEmpty ? nil : notes
            viewModel.updateItem(existing)
        } else {
            let newItem = PantryItem(
                name: cleanName,
                normalizedName: cleanName,
                category: category,
                location: location,
                quantity: quantity,
                unit: unit,
                purchasePrice: price,
                purchaseDate: purchaseDate,
                expirationDate: expirationDate,
                notes: notes.isEmpty ? nil : notes
            )
            viewModel.addItem(newItem)
        }
    }
}

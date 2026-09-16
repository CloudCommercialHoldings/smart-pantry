import SwiftUI

public struct ReceiptReviewView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ScannerViewModel
    
    @State private var editingItemIndex: Int? = nil
    
    public var body: some View {
        NavigationView {
            if let receipt = viewModel.currentReceipt {
                ScrollView {
                    VStack(spacing: 16) {
                        // Duplicate Warning Banner
                        if viewModel.duplicateWarning {
                            HStack(spacing: 12) {
                                Image(systemName: "exclamationmark.octagon.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Duplicate Receipt Detected")
                                        .font(.subheadline.weight(.bold))
                                        .foregroundColor(.red)
                                    Text("A receipt from \(receipt.storeName) with total $\(receipt.totalAmount, specifier: "%.2f") already exists in your history.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color.red.opacity(0.12))
                            .cornerRadius(12)
                            .padding(.horizontal)
                        }
                        
                        // Receipt Meta Header Card
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Label(receipt.storeName, systemImage: "cart.fill")
                                    .font(.title3.weight(.bold))
                                Spacer()
                                Text(receipt.purchaseDate, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                            
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Subtotal: $\(receipt.subtotal, specifier: "%.2f")")
                                    Text("Tax: $\(receipt.tax, specifier: "%.2f")")
                                }
                                .font(.caption)
                                .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    Text("Total Amount")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("$\(receipt.totalAmount, specifier: "%.2f")")
                                        .font(.title2.weight(.bold))
                                        .foregroundColor(.accentColor)
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Confidence Flagging Notice
                        if receipt.uncertainItemCount > 0 {
                            HStack(spacing: 8) {
                                Image(systemName: "questionmark.circle.fill")
                                    .foregroundColor(.orange)
                                Text("\(receipt.uncertainItemCount) item(s) flagged for user confirmation.")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(.orange)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Extracted Items Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Extracted Line Items (\(receipt.items.count))")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(Array(receipt.items.enumerated()), id: \.element.id) { index, item in
                                ReviewItemRow(
                                    item: item,
                                    onEdit: { editingItemIndex = index },
                                    onDelete: { viewModel.deleteItemFromReview(index: index) }
                                )
                                .padding(.horizontal)
                            }
                        }
                        
                        // Import to Pantry Toggle
                        Toggle(isOn: $viewModel.importToPantry) {
                            HStack {
                                Image(systemName: "cabinet.fill")
                                    .foregroundColor(.accentColor)
                                VStack(alignment: .leading) {
                                    Text("Add Items to Smart Pantry")
                                        .font(.headline)
                                    Text("Automatically calculates expiry dates and schedules alerts.")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemGroupedBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        .padding(.top, 8)
                        
                        // Save Action Button
                        Button {
                            viewModel.saveCurrentReceipt()
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Label("Save Receipt & Import Items", systemImage: "checkmark.seal.fill")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(14)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                    .padding(.vertical)
                }
                .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
                .navigationTitle("Receipt Intelligence")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
                .sheet(item: Binding<ReviewEditItem?>(
                    get: {
                        if let idx = editingItemIndex, idx < receipt.items.count {
                            return ReviewEditItem(index: idx, item: receipt.items[idx])
                        }
                        return nil
                    },
                    set: { _ in editingItemIndex = nil }
                )) { editData in
                    EditReviewItemSheet(
                        item: editData.item,
                        onSave: { name, cat, loc, price, qty in
                            viewModel.updateItemInReview(
                                index: editData.index,
                                name: name,
                                category: cat,
                                location: loc,
                                price: price,
                                quantity: qty
                            )
                        }
                    )
                }
            }
        }
    }
}

struct ReviewEditItem: Identifiable {
    let id = UUID()
    let index: Int
    let item: ReceiptItem
}

struct ReviewItemRow: View {
    let item: ReceiptItem
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Category Icon
            Image(systemName: item.category.iconName)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(item.category.categoryColor)
                .frame(width: 36, height: 36)
                .background(item.category.categoryColor.opacity(0.12))
                .clipShape(Circle())
            
            // Extracted Product Info
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 6) {
                    Text(item.normalizedName)
                        .font(.body.weight(.semibold))
                    
                    // Confidence Tag
                    Text(item.confidence.rawValue)
                        .font(.caption2.weight(.bold))
                        .foregroundColor(item.confidence.badgeColor)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(item.confidence.badgeColor.opacity(0.15))
                        .cornerRadius(6)
                }
                
                if item.rawDescription != item.normalizedName {
                    Text("RAW: \(item.rawDescription)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                HStack(spacing: 8) {
                    Text(item.suggestedLocation.rawValue)
                        .font(.caption2)
                        .foregroundColor(item.suggestedLocation.themeColor)
                    
                    Text("• Qty: \(item.quantity, specifier: "%.1f")")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Price & Actions
            VStack(alignment: .trailing, spacing: 4) {
                Text("$\(item.totalPrice, specifier: "%.2f")")
                    .font(.callout.weight(.bold))
                
                HStack(spacing: 8) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.accentColor)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.red)
                    }
                }
            }
        }
        .padding(12)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

struct EditReviewItemSheet: View {
    @Environment(\.presentationMode) var presentationMode
    let item: ReceiptItem
    let onSave: (String, ItemCategory, StorageLocation, Double, Double) -> Void
    
    @State private var name: String = ""
    @State private var category: ItemCategory = .produce
    @State private var location: StorageLocation = .fridge
    @State private var priceString: String = ""
    @State private var quantity: Double = 1.0
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Raw OCR Text")) {
                    Text(item.rawDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section(header: Text("Normalized Product Name")) {
                    TextField("Product Name", text: $name)
                }
                
                Section(header: Text("Category & Storage Location")) {
                    Picker("Category", selection: $category) {
                        ForEach(ItemCategory.allCases) { cat in
                            Label(cat.rawValue, systemImage: cat.iconName).tag(cat)
                        }
                    }
                    
                    Picker("Storage Location", selection: $location) {
                        ForEach(StorageLocation.allCases) { loc in
                            Label(loc.rawValue, systemImage: loc.iconName).tag(loc)
                        }
                    }
                }
                
                Section(header: Text("Price & Quantity")) {
                    HStack {
                        Text("Price ($)")
                        Spacer()
                        TextField("0.00", text: $priceString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Stepper("Quantity: \(quantity, specifier: "%.1f")", value: $quantity, in: 0.5...50, step: 0.5)
                }
            }
            .navigationTitle("Correct Receipt Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let price = Double(priceString) ?? item.totalPrice
                        onSave(name, category, location, price, quantity)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                self.name = item.normalizedName
                self.category = item.category
                self.location = item.suggestedLocation
                self.priceString = String(format: "%.2f", item.totalPrice)
                self.quantity = item.quantity
            }
        }
    }
}

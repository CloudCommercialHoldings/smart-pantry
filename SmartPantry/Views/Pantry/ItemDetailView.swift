import SwiftUI

public struct ItemDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: PantryViewModel
    @State var item: PantryItem
    
    @State private var isEditing: Bool = false
    @State private var showDeleteConfirm: Bool = false
    
    public init(viewModel: PantryViewModel, item: PantryItem) {
        self.viewModel = viewModel
        self._item = State(initialValue: item)
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Food Photo or Header Card
                VStack(spacing: 14) {
                    if let imgData = item.itemImageData, let uiImage = UIImage(data: imgData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .frame(maxWidth: .infinity)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: Color.black.opacity(0.08), radius: 6, x: 0, y: 3)
                    } else {
                        ZStack {
                            Circle()
                                .fill(item.category.categoryColor.opacity(0.15))
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: item.category.iconName)
                                .font(.system(size: 36, weight: .bold))
                                .foregroundColor(item.category.categoryColor)
                        }
                    }
                    
                    Text(item.name)
                        .font(.title2.weight(.bold))
                        .multilineTextAlignment(.center)
                    
                    HStack(spacing: 12) {
                        Label(item.category.rawValue, systemImage: item.category.iconName)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(item.category.categoryColor.opacity(0.12))
                            .foregroundColor(item.category.categoryColor)
                            .cornerRadius(10)
                        
                        Label(item.location.rawValue, systemImage: item.location.iconName)
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(item.location.themeColor.opacity(0.12))
                            .foregroundColor(item.location.themeColor)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(20)
                
                // Expiry Countdown Card
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("Expiration Status")
                            .font(.headline)
                        Spacer()
                        Text(item.expiryStatus.rawValue)
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(item.expiryStatus.badgeColor)
                    }
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Expires On")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(item.expirationDate, style: .date)
                                .font(.title3.weight(.semibold))
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Time Remaining")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(item.daysUntilExpiration) Days")
                                .font(.title3.weight(.bold))
                                .foregroundColor(item.expiryStatus.badgeColor)
                        }
                    }
                    
                    Divider()
                    
                    Text("Extend Expiration Date:")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 10) {
                        Button("+3 Days") {
                            viewModel.extendExpiration(for: item, byDays: 3)
                            refreshItem()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("+7 Days") {
                            viewModel.extendExpiration(for: item, byDays: 7)
                            refreshItem()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("+1 Month") {
                            viewModel.extendExpiration(for: item, byDays: 30)
                            refreshItem()
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(20)
                
                // Details Card
                VStack(alignment: .leading, spacing: 12) {
                    Text("Details")
                        .font(.headline)
                    
                    DetailRow(title: "Quantity", value: "\(item.quantity) \(item.unit)")
                    
                    if let price = item.purchasePrice {
                        DetailRow(title: "Purchase Price", value: String(format: "$%.2f", price))
                    }
                    
                    DetailRow(title: "Date Added", value: item.purchaseDate.formatted(date: .abbreviated, time: .omitted))
                    
                    if let notes = item.notes, !notes.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Notes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(notes)
                                .font(.body)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(20)
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button {
                        viewModel.markConsumed(item)
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Label("Mark as Consumed", systemImage: "checkmark.circle.fill")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(14)
                    }
                    
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Delete Item", systemImage: "trash")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.12))
                            .foregroundColor(.red)
                            .cornerRadius(14)
                    }
                }
                .padding(.top, 10)
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    isEditing = true
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            AddEditItemView(viewModel: viewModel, itemToEdit: item)
        }
        .confirmationDialog("Delete Item?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                viewModel.deleteItem(item)
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
    
    private func refreshItem() {
        if let updated = viewModel.filteredItems.first(where: { $0.id == item.id }) {
            self.item = updated
        }
    }
}

public struct DetailRow: View {
    let title: String
    let value: String
    
    public init(title: String, value: String) {
        self.title = title
        self.value = value
    }
    
    public var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .weight(.semibold)
        }
        .font(.subheadline)
    }
}

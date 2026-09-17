import SwiftUI

public struct ReceiptFilterView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ReceiptHistoryViewModel
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Date Range")) {
                    Picker("Time Period", selection: $viewModel.selectedDateRange) {
                        ForEach(DateRangeFilter.allCases) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                }
                
                Section(header: Text("Filter by Store")) {
                    Button("All Stores") {
                        viewModel.selectedStoreFilter = nil
                    }
                    .foregroundColor(viewModel.selectedStoreFilter == nil ? .accentColor : .primary)
                    
                    ForEach(viewModel.allStores, id: \.self) { store in
                        HStack {
                            Text(store)
                            Spacer()
                            if viewModel.selectedStoreFilter == store {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedStoreFilter = store
                        }
                    }
                }
                
                Section(header: Text("Filter by Category")) {
                    Button("All Categories") {
                        viewModel.selectedCategoryFilter = nil
                    }
                    .foregroundColor(viewModel.selectedCategoryFilter == nil ? .accentColor : .primary)
                    
                    ForEach(ItemCategory.allCases) { cat in
                        HStack {
                            Label(cat.rawValue, systemImage: cat.iconName)
                            Spacer()
                            if viewModel.selectedCategoryFilter == cat {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.selectedCategoryFilter = cat
                        }
                    }
                }
            }
            .navigationTitle("Filter Receipts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

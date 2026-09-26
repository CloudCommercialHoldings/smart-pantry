import SwiftUI

public struct ReceiptFilterView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ReceiptHistoryViewModel
    @ObservedObject var subService = SubscriptionService.shared
    
    @State private var showPaywall: Bool = false
    
    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Date Range"), footer: Text("Default filter is 'This Month'. Yearly and 5 Years date ranges are unlocked with SmartPantry Pro.")) {
                    ForEach(DateRangeFilter.allCases) { range in
                        HStack {
                            Text(range.rawValue)
                                .foregroundColor(range.isProOnly && !subService.isPro ? .secondary : .primary)
                            
                            Spacer()
                            
                            if range.isProOnly {
                                Label("PRO", systemImage: "crown.fill")
                                    .font(.caption2.weight(.bold))
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.purple.opacity(0.15))
                                    .foregroundColor(.purple)
                                    .cornerRadius(6)
                            }
                            
                            if viewModel.selectedDateRange == range {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.accentColor)
                                    .fontWeight(.bold)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            if range.isProOnly && !subService.isPro {
                                showPaywall = true
                            } else {
                                viewModel.selectedDateRange = range
                            }
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
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

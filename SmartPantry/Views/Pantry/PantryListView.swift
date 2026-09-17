import SwiftUI

public struct PantryListView: View {
    @StateObject var viewModel = PantryViewModel()
    @ObservedObject var subService = SubscriptionService.shared
    
    @State private var showAddItemSheet: Bool = false
    @State private var showPaywall: Bool = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Top Expiry Alert Summary Banner
                if viewModel.expiringSoonCount > 0 || viewModel.expiredCount > 0 {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.title3)
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Inventory Alert")
                                .font(.subheadline.weight(.bold))
                            
                            Text("\(viewModel.expiringSoonCount) expiring soon • \(viewModel.expiredCount) expired")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        NavigationLink(destination: ExpiringSoonView(viewModel: viewModel)) {
                            Text("Review")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange)
                                .cornerRadius(10)
                        }
                    }
                    .padding(14)
                    .background(Color.orange.opacity(0.12))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                
                // Horizontal Location Selector Pills
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        FilterPill(
                            title: "All Items",
                            icon: "square.grid.2x2.fill",
                            isSelected: viewModel.selectedLocation == nil,
                            color: .accentColor
                        ) {
                            viewModel.selectedLocation = nil
                        }
                        
                        ForEach(StorageLocation.allCases) { loc in
                            FilterPill(
                                title: loc.rawValue,
                                icon: loc.iconName,
                                isSelected: viewModel.selectedLocation == loc,
                                color: loc.themeColor
                            ) {
                                viewModel.selectedLocation = loc
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 12)
                }
                
                // Items List
                if viewModel.filteredItems.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "basket.fill")
                            .font(.system(size: 54))
                            .foregroundColor(.secondary)
                        
                        Text("No Pantry Items Found")
                            .font(.title3.weight(.bold))
                            .foregroundColor(.secondary)
                        
                        Text("Scan a grocery receipt or tap '+' to add items with custom photos.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        
                        Button {
                            showAddItemSheet = true
                        } label: {
                            Label("Add First Item", systemImage: "plus.circle.fill")
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)
                        
                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.filteredItems) { item in
                                NavigationLink(destination: ItemDetailView(viewModel: viewModel, item: item)) {
                                    PantryItemRowView(
                                        item: item,
                                        onConsume: { viewModel.markConsumed(item) },
                                        onExtend: { viewModel.extendExpiration(for: item, byDays: 3) }
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Smart Pantry")
            .searchable(text: $viewModel.searchText, prompt: "Search pantry items...")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack(spacing: 8) {
                        Button {
                            showPaywall = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: subService.isPro ? "crown.fill" : "crown")
                                    .font(.caption.weight(.bold))
                                Text(subService.isPro ? "Pro" : "Upgrade")
                                    .font(.caption.weight(.bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(subService.isPro ? Color.purple : Color.orange)
                            .cornerRadius(12)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Menu {
                            Picker("Sort By", selection: $viewModel.sortOption) {
                                ForEach(PantrySortOption.allCases) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                        } label: {
                            Image(systemName: "arrow.up.arrow.down.circle")
                                .font(.title3)
                        }
                        
                        Button {
                            showAddItemSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                        }
                    }
                }
            }
            .sheet(isPresented: $showAddItemSheet) {
                AddEditItemView(viewModel: viewModel)
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }
}

public struct FilterPill: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    public init(title: String, icon: String, isSelected: Bool, color: Color, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.isSelected = isSelected
        self.color = color
        self.action = action
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color(UIColor.secondarySystemFill))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

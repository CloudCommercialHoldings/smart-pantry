import SwiftUI

public struct PantryListView: View {
    @StateObject var viewModel = PantryViewModel()
    @ObservedObject var subService = SubscriptionService.shared
    @ObservedObject var authService = AuthService.shared
    @ObservedObject var gamification = GamificationService.shared
    
    @State private var showAddItemSheet: Bool = false
    @State private var showPaywall: Bool = false
    @State private var showRecentlyDeleted: Bool = false
    @State private var showRewards: Bool = false
    @State private var showSignOutAlert: Bool = false
    
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
                
                // Floating Undo Snackbar Banner
                if let undo = viewModel.lastUndoAction {
                    HStack(spacing: 12) {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .font(.title3)
                            .foregroundColor(.yellow)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(undo.message)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(.white)
                                .lineLimit(1)
                            Text("Tap Undo to restore item immediately")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.spring()) {
                                viewModel.undoLastAction()
                            }
                        } label: {
                            Text("UNDO")
                                .font(.caption.weight(.bold))
                                .foregroundColor(.black)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.yellow)
                                .cornerRadius(8)
                        }
                    }
                    .padding(14)
                    .background(Color.black.opacity(0.9))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)
                    .padding(.bottom, 10)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
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
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(subService.isPro ? Color.purple : Color.orange)
                            .cornerRadius(10)
                        }
                        
                        Button {
                            showRewards = true
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: gamification.currentLevel.badgeIcon)
                                    .font(.caption.weight(.bold))
                                Text(gamification.currentLevel.rawValue)
                                    .font(.caption.weight(.semibold))
                            }
                            .foregroundColor(gamification.currentLevel.badgeColor)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(gamification.currentLevel.badgeColor.opacity(0.15))
                            .cornerRadius(10)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack(spacing: 12) {
                        Button {
                            showRecentlyDeleted = true
                        } label: {
                            Image(systemName: "arrow.uturn.backward.circle")
                                .font(.title3)
                        }
                        
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
                        
                        Menu {
                            if let email = authService.currentUser?.email {
                                Text("Signed in as:\n\(email)")
                                Divider()
                            }
                            Button(role: .destructive) {
                                showSignOutAlert = true
                            } label: {
                                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
                            }
                        } label: {
                            Image(systemName: "person.crop.circle")
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
            .sheet(isPresented: $showRecentlyDeleted) {
                RecentlyDeletedView(viewModel: viewModel)
            }
            .sheet(isPresented: $showRewards) {
                PantryRewardsView()
            }
            .alert("Sign Out", isPresented: $showSignOutAlert) {
                Button("Sign Out", role: .destructive) {
                    authService.signOut()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to sign out of SmartPantry?")
            }
        }
        .navigationViewStyle(.stack)
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

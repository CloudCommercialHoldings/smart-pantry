import SwiftUI

public struct ExpiringSoonView: View {
    @ObservedObject var viewModel: PantryViewModel
    
    public init(viewModel: PantryViewModel) {
        self.viewModel = viewModel
    }
    
    public var urgentItems: [PantryItem] {
        viewModel.filteredItems.filter { !$0.isConsumed && ($0.expiryStatus == .expiringSoon || $0.expiryStatus == .expired) }
            .sorted(by: { $0.expirationDate < $1.expirationDate })
    }
    
    public var body: some View {
        VStack {
            if urgentItems.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 56))
                        .foregroundColor(.green)
                    Text("All Items Fresh!")
                        .font(.title2.weight(.bold))
                    Text("No items are expiring in the next 3 days. Excellent job managing your pantry!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    Spacer()
                }
            } else {
                List {
                    Section(header: Text("Items Requiring Attention (\(urgentItems.count))")) {
                        ForEach(urgentItems) { item in
                            PantryItemRowView(
                                item: item,
                                onConsume: { viewModel.markConsumed(item) },
                                onExtend: { viewModel.extendExpiration(for: item, byDays: 3) }
                            )
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Expiring Soon")
        .navigationBarTitleDisplayMode(.inline)
    }
}

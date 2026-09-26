import SwiftUI

public struct RecentlyDeletedView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: PantryViewModel
    
    public init(viewModel: PantryViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationView {
            Group {
                if viewModel.recentlyDeletedItems.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "trash.slash.fill")
                            .font(.system(size: 54))
                            .foregroundColor(.secondary)
                        Text("No Recently Deleted Items")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("Items deleted or marked as completed will appear here so you can undo or restore them anytime.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(viewModel.recentlyDeletedItems) { item in
                            HStack(spacing: 12) {
                                Image(systemName: item.category.iconName)
                                    .foregroundColor(item.category.categoryColor)
                                    .frame(width: 32, height: 32)
                                    .background(item.category.categoryColor.opacity(0.12))
                                    .clipShape(Circle())
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.subheadline.weight(.semibold))
                                    Text(item.location.rawValue)
                                        .font(.caption2)
                                        .foregroundColor(item.location.themeColor)
                                }
                                
                                Spacer()
                                
                                Button {
                                    withAnimation {
                                        viewModel.restoreDeletedItem(item)
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: "arrow.uturn.backward.circle.fill")
                                        Text("Restore")
                                    }
                                    .font(.caption.weight(.bold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.accentColor)
                                    .cornerRadius(8)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Recently Deleted")
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

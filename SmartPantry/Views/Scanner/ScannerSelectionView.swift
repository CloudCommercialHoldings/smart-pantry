import SwiftUI

public struct ScannerSelectionView: View {
    @StateObject var viewModel = ScannerViewModel()
    
    @State private var showDocumentCamera: Bool = false
    @State private var showBarcodeScanner: Bool = false
    @State private var showPhotoPicker: Bool = false
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Banner
                    VStack(spacing: 8) {
                        Image(systemName: "doc.viewfinder.fill")
                            .font(.system(size: 56))
                            .foregroundColor(.accentColor)
                        
                        Text("Smart Grocery Scanner")
                            .font(.title.weight(.bold))
                        
                        Text("Scan paper receipts or barcodes to automatically log items and estimate expiration dates.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }
                    .padding(.top, 16)
                    
                    // Primary Actions Grid
                    VStack(spacing: 16) {
                        // Document Camera Button
                        ScanOptionCard(
                            title: "Scan Receipt Camera",
                            subtitle: "Native VisionKit camera with auto edge-detection and multi-page receipt capture.",
                            icon: "doc.text.viewfinder",
                            badgeText: "Recommended",
                            color: .accentColor
                        ) {
                            showDocumentCamera = true
                        }
                        
                        // Live Barcode Scanner Button
                        ScanOptionCard(
                            title: "Live Barcode Reader",
                            subtitle: "Scan UPC product barcodes directly into your pantry inventory.",
                            icon: "barcode.viewfinder",
                            badgeText: nil,
                            color: .green
                        ) {
                            showBarcodeScanner = true
                        }
                        
                        // Photo Library Picker Button
                        ScanOptionCard(
                            title: "Import Photo from Library",
                            subtitle: "Select saved receipt photos or screenshots from your photo library.",
                            icon: "photo.stack.fill",
                            badgeText: nil,
                            color: .purple
                        ) {
                            showPhotoPicker = true
                        }
                    }
                    .padding(.horizontal)
                    
                    // Demo Simulator Quick Test Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instant Demo Receipts (Simulator)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Text("Tap any sample store receipt to test Vision OCR, abbreviation normalization, confidence flagging, and duplicate detection:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            DemoStoreButton(name: "Trader Joe's", icon: "cart.fill", color: .red) {
                                viewModel.processSampleReceipt(storeName: "Trader Joe's")
                            }
                            
                            DemoStoreButton(name: "Whole Foods", icon: "leaf.fill", color: .green) {
                                viewModel.processSampleReceipt(storeName: "Whole Foods")
                            }
                            
                            DemoStoreButton(name: "Kroger", icon: "bag.fill", color: .blue) {
                                viewModel.processSampleReceipt(storeName: "Kroger")
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Scanner")
            .sheet(isPresented: $showDocumentCamera) {
                DocumentCameraView(
                    onScanCompleted: { image in
                        viewModel.processImage(image)
                    },
                    onCancel: {}
                )
            }
            .sheet(isPresented: $showBarcodeScanner) {
                BarcodeScannerView { code in
                    // Add mock item by barcode lookup
                    let metadata = ExpiryDatabaseService.shared.predictMetadata(itemName: "Scanned Item (\(code))")
                    let item = PantryItem(
                        name: "Scanned Product (\(code.prefix(6)))",
                        category: metadata.category,
                        location: metadata.location,
                        expirationDate: metadata.expirationDate,
                        barcode: code
                    )
                    StorageService.shared.addPantryItem(item)
                }
            }
            .sheet(isPresented: $showPhotoPicker) {
                PhotoPickerScannerView(viewModel: viewModel)
            }
            .fullScreenCover(isPresented: $viewModel.showReceiptReview) {
                ReceiptReviewView(viewModel: viewModel)
            }
            .overlay {
                if viewModel.isProcessing {
                    ZStack {
                        Color.black.opacity(0.4).ignoresSafeArea()
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.4)
                                .tint(.white)
                            Text(viewModel.statusMessage)
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding(24)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(16)
                        .shadow(radius: 10)
                    }
                }
            }
        }
    }
}

struct ScanOptionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let badgeText: String?
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(color.opacity(0.15))
                        .frame(width: 54, height: 54)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if let badge = badgeText {
                            Text(badge)
                                .font(.caption2.weight(.bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(color)
                                .cornerRadius(6)
                        }
                    }
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }
}

struct DemoStoreButton: View {
    let name: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                Text(name)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
}

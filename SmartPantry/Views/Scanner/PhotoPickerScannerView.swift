import SwiftUI
import PhotosUI

public struct PhotoPickerScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var viewModel: ScannerViewModel
    
    @State private var selectedItem: PhotosPickerItem? = nil
    
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
                .padding(.top, 40)
            
            Text("Select Receipt Image")
                .font(.title2.weight(.bold))
            
            Text("Choose a photo of a store receipt from your library for on-device Vision OCR text recognition.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            PhotosPicker(
                selection: $selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label("Choose Photo from Library", systemImage: "photo.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
            .padding(.top, 16)
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        viewModel.processImage(image)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

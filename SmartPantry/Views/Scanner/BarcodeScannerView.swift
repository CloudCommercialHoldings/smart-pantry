import SwiftUI
import AVFoundation

public struct BarcodeScannerView: View {
    @Environment(\.presentationMode) var presentationMode
    let onBarcodeScanned: (String) -> Void
    
    @State private var simulatedBarcode: String = "078742351829" // Sample UPCA
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                HStack {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    
                    Spacer()
                }
                
                Spacer()
                
                // Target Reticle
                ZStack {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green, lineWidth: 3)
                        .frame(width: 260, height: 160)
                    
                    Rectangle()
                        .fill(Color.red)
                        .frame(width: 240, height: 2)
                }
                
                Text("Align Barcode within Frame")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)
                    .padding(.top, 16)
                
                Spacer()
                
                // Simulator Quick Test Barcode Button
                VStack(spacing: 8) {
                    Text("Simulator Test Options")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    HStack(spacing: 12) {
                        Button("Scan Milk (078742351829)") {
                            onBarcodeScanned("078742351829")
                            presentationMode.wrappedValue.dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.cyan)
                        
                        Button("Scan Chicken (021000612239)") {
                            onBarcodeScanned("021000612239")
                            presentationMode.wrappedValue.dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.orange)
                    }
                }
                .padding(.bottom, 30)
            }
        }
    }
}

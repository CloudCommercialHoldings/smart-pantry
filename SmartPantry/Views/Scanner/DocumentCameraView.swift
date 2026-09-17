import SwiftUI

#if !targetEnvironment(macCatalyst)
import VisionKit

public struct DocumentCameraView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    let onScanCompleted: (UIImage) -> Void
    let onCancel: () -> Void
    
    public init(onScanCompleted: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
        self.onScanCompleted = onScanCompleted
        self.onCancel = onCancel
    }
    
    public func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }
    
    public func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}
    
    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    public class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let parent: DocumentCameraView
        
        init(_ parent: DocumentCameraView) {
            self.parent = parent
        }
        
        public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            if scan.pageCount > 0 {
                let firstPage = scan.imageOfPage(at: 0)
                parent.onScanCompleted(firstPage)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        public func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            parent.onCancel()
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        public func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("Document camera error: \(error)")
            parent.onCancel()
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
#else
public struct DocumentCameraView: View {
    @Environment(\.presentationMode) var presentationMode
    let onScanCompleted: (UIImage) -> Void
    let onCancel: () -> Void
    
    public init(onScanCompleted: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
        self.onScanCompleted = onScanCompleted
        self.onCancel = onCancel
    }
    
    public var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            Text("Camera Scanner")
                .font(.title2.weight(.bold))
            Text("Document camera is available on iOS devices with a camera. On Mac, use the Photo Library option or test with the built-in instant demo receipts!")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            Button("Dismiss") {
                onCancel()
                presentationMode.wrappedValue.dismiss()
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 10)
        }
        .padding(32)
        .frame(minWidth: 350, minHeight: 280)
    }
}
#endif

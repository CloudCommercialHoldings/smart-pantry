import SwiftUI
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

import Foundation
import UIKit
import SwiftUI
import Combine

public class ScannerViewModel: ObservableObject {
    @Published public var isProcessing: Bool = false
    @Published public var statusMessage: String = ""
    @Published public var currentReceipt: ReceiptRecord? = nil
    @Published public var capturedImage: UIImage? = nil
    @Published public var showReceiptReview: Bool = false
    @Published public var duplicateWarning: Bool = false
    @Published public var importToPantry: Bool = true
    
    private let storage: StorageService
    
    public init(storage: StorageService = .shared) {
        self.storage = storage
    }
    
    /// Processes a scanned image (or sample demo store) with Vision framework
    public func processImage(_ image: UIImage) {
        self.capturedImage = image
        self.isProcessing = true
        self.statusMessage = "Scanning receipt with Vision OCR..."
        
        ReceiptOCRService.shared.recognizeText(in: image) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isProcessing = false
                
                switch result {
                case .success(let lines):
                    if lines.isEmpty {
                        self.processSampleReceipt(storeName: "Trader Joe's")
                    } else {
                        self.parseLines(lines)
                    }
                case .failure:
                    self.processSampleReceipt(storeName: "Trader Joe's")
                }
            }
        }
    }
    
    /// Fallback / Demo scan simulator
    public func processSampleReceipt(storeName: String) {
        self.isProcessing = true
        self.statusMessage = "Processing receipt for \(storeName)..."
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            guard let self = self else { return }
            self.isProcessing = false
            let lines = ReceiptOCRService.shared.getSampleReceiptLines(for: storeName)
            self.parseLines(lines)
        }
    }
    
    public func parseLines(_ lines: [String]) {
        var parsed = ReceiptParserEngine.shared.parse(
            lines: lines,
            savedRules: storage.ocrRules,
            existingReceipts: storage.receipts
        )
        
        if let image = capturedImage, let data = image.jpegData(compressionQuality: 0.7) {
            parsed.receiptImageData = data
        }
        
        self.currentReceipt = parsed
        self.duplicateWarning = parsed.isDuplicate
        self.showReceiptReview = true
    }
    
    // MARK: - Review & Corrections
    
    public func updateItemInReview(index: Int, name: String, category: ItemCategory, location: StorageLocation, price: Double, quantity: Double) {
        guard var receipt = currentReceipt, index >= 0 && index < receipt.items.count else { return }
        let oldItem = receipt.items[index]
        
        var updatedItem = oldItem
        updatedItem.normalizedName = name
        updatedItem.category = category
        updatedItem.suggestedLocation = location
        updatedItem.totalPrice = price
        updatedItem.quantity = quantity
        updatedItem.confidence = .high
        updatedItem.isConfirmedByUser = true
        
        receipt.items[index] = updatedItem
        
        // Recalculate Subtotal & Total
        let newSub = receipt.items.reduce(0.0) { $0 + $1.totalPrice }
        receipt.subtotal = newSub
        receipt.totalAmount = newSub + receipt.tax - receipt.savings
        
        self.currentReceipt = receipt
        
        // Save user correction rule for future intelligence learning
        storage.addOrUpdateOCRRule(
            rawText: oldItem.rawDescription,
            correctedName: name,
            category: category,
            location: location
        )
    }
    
    public func deleteItemFromReview(index: Int) {
        guard var receipt = currentReceipt, index >= 0 && index < receipt.items.count else { return }
        receipt.items.remove(at: index)
        let newSub = receipt.items.reduce(0.0) { $0 + $1.totalPrice }
        receipt.subtotal = newSub
        receipt.totalAmount = newSub + receipt.tax - receipt.savings
        self.currentReceipt = receipt
    }
    
    public func saveCurrentReceipt() {
        guard let receipt = currentReceipt else { return }
        storage.addReceiptRecord(receipt, importToPantry: importToPantry)
        self.showReceiptReview = false
        self.currentReceipt = nil
        self.capturedImage = nil
    }
}

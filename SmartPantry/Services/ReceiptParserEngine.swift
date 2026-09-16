import Foundation

public class ReceiptParserEngine {
    public static let shared = ReceiptParserEngine()
    
    public init() {}
    
    /// Parses array of raw text lines into a structured `ReceiptRecord`
    public func parse(
        lines: [String],
        savedRules: [OCRCorrectionRule] = [],
        existingReceipts: [ReceiptRecord] = []
    ) -> ReceiptRecord {
        var storeName = "Grocery Store"
        var purchaseDate = Date()
        var subtotal: Double = 0.0
        var tax: Double = 0.0
        var totalAmount: Double = 0.0
        var savings: Double = 0.0
        var paymentMethod = "Card"
        var items: [ReceiptItem] = []
        
        let fullRawText = lines.joined(separator: "\n")
        
        // 1. Store Name Detection
        if let headerLine = lines.first(where: { !$0.trimmingCharacters(in: .whitespaces).isEmpty }) {
            storeName = cleanStoreName(headerLine)
        }
        
        // 2. Date Extraction
        let datePattern = "(\\d{1,2}[/-]\\d{1,2}[/-]\\d{2,4})"
        if let regex = try? NSRegularExpression(pattern: datePattern),
           let match = regex.firstMatch(in: fullRawText, options: [], range: NSRange(location: 0, length: fullRawText.utf16.count)) {
            let nsRange = match.range(at: 1)
            if let range = Range(nsRange, in: fullRawText) {
                let dateString = String(fullRawText[range])
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                if let parsedDate = formatter.date(from: dateString) {
                    purchaseDate = parsedDate
                } else {
                    formatter.dateFormat = "MM/dd/yy"
                    if let parsedDate = formatter.date(from: dateString) {
                        purchaseDate = parsedDate
                    }
                }
            }
        }
        
        // 3. Process line by line for metadata vs items
        for line in lines {
            let upper = line.uppercased().trimmingCharacters(in: .whitespaces)
            
            if upper.contains("SUBTOTAL") {
                if let val = extractPrice(from: upper) { subtotal = val }
                continue
            }
            
            if upper.contains("TAX") && !upper.contains("TOTAL") {
                if let val = extractPrice(from: upper) { tax = val }
                continue
            }
            
            if upper.contains("TOTAL") || upper.contains("AMOUNT DUE") {
                if let val = extractPrice(from: upper) { totalAmount = val }
                continue
            }
            
            if upper.contains("SAVINGS") || upper.contains("DISCOUNT") || upper.contains("SAVED") {
                if let val = extractPrice(from: upper) { savings = val }
                continue
            }
            
            if upper.contains("VISA") { paymentMethod = "Visa" ; continue }
            if upper.contains("MASTERCARD") || upper.contains("MC ") { paymentMethod = "Mastercard" ; continue }
            if upper.contains("AMEX") || upper.contains("AMERICAN EXPRESS") { paymentMethod = "Amex" ; continue }
            if upper.contains("APPLE PAY") { paymentMethod = "Apple Pay" ; continue }
            if upper.contains("CASH") { paymentMethod = "Cash" ; continue }
            
            // Skip non-item decoration lines
            if upper.contains("----------------") || upper.contains("=========") || upper.contains("THANK YOU") || upper.contains("STORE #") || upper.contains("TEL:") {
                continue
            }
            
            // Try to parse line item
            if let price = extractPrice(from: line) {
                let descriptionPart = removePriceFromLine(line)
                let trimmedDesc = descriptionPart.trimmingCharacters(in: .whitespacesAndNewlines)
                
                if trimmedDesc.count >= 2 && !isHeaderFooterWord(trimmedDesc) {
                    // Check if learned user rule exists for this raw description
                    let upperDesc = trimmedDesc.uppercased()
                    let (normName, category, location, confidence) = processItemIntelligence(
                        rawDescription: trimmedDesc,
                        savedRules: savedRules
                    )
                    
                    let (qty, unitP) = extractQuantityAndUnitPrice(from: line)
                    
                    let item = ReceiptItem(
                        rawLine: line,
                        rawDescription: trimmedDesc,
                        normalizedName: normName,
                        category: category,
                        suggestedLocation: location,
                        quantity: qty,
                        unitPrice: unitP,
                        totalPrice: price,
                        confidence: confidence,
                        isConfirmedByUser: confidence == .high
                    )
                    items.append(item)
                }
            }
        }
        
        // Fallback calculations for subtotal/total
        let itemsSum = items.reduce(0.0) { $0 + $1.totalPrice }
        if subtotal == 0.0 { subtotal = itemsSum }
        if totalAmount == 0.0 { totalAmount = subtotal + tax - savings }
        
        // Check for duplicate receipt
        let isDup = checkIsDuplicate(storeName: storeName, purchaseDate: purchaseDate, totalAmount: totalAmount, existing: existingReceipts)
        
        return ReceiptRecord(
            storeName: storeName,
            purchaseDate: purchaseDate,
            scanDate: Date(),
            subtotal: subtotal,
            tax: tax,
            totalAmount: totalAmount,
            savings: savings,
            paymentMethod: paymentMethod,
            items: items,
            rawText: fullRawText,
            isDuplicate: isDup
        )
    }
    
    public func checkIsDuplicate(
        storeName: String,
        purchaseDate: Date,
        totalAmount: Double,
        existing: [ReceiptRecord]
    ) -> Bool {
        let calendar = Calendar.current
        return existing.contains { receipt in
            let sameStore = receipt.storeName.lowercased() == storeName.lowercased()
            let sameDate = calendar.isDate(receipt.purchaseDate, inSameDayAs: purchaseDate)
            let sameTotal = abs(receipt.totalAmount - totalAmount) < 0.05
            return sameStore && sameDate && sameTotal
        }
    }
    
    private func processItemIntelligence(
        rawDescription: String,
        savedRules: [OCRCorrectionRule]
    ) -> (name: String, category: ItemCategory, location: StorageLocation, confidence: OCRConfidence) {
        let upperDesc = rawDescription.uppercased().trimmingCharacters(in: .whitespaces)
        
        // 1. Check user-saved correction rules first
        if let match = savedRules.first(where: { $0.originalRawText == upperDesc }) {
            return (match.correctedName, match.correctedCategory, match.correctedLocation, .high)
        }
        
        // 2. Abbreviation Normalizer
        let normalized = AbbreviationNormalizer.shared.normalize(rawDescription)
        
        // 3. Expiry & Category predictor
        let metadata = ExpiryDatabaseService.shared.predictMetadata(itemName: normalized)
        
        // 4. Calculate Confidence
        var confidence: OCRConfidence = .high
        if rawDescription.count < 3 || rawDescription.contains("?") || rawDescription.contains("#") {
            confidence = .low
        } else if rawDescription == normalized && !rawDescription.contains(" ") {
            confidence = .medium
        }
        
        return (normalized, metadata.category, metadata.location, confidence)
    }
    
    private func cleanStoreName(_ rawHeader: String) -> String {
        let header = rawHeader.replacingOccurrences(of: "#[0-9]+", with: "", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if header.lowercased().contains("trader") { return "Trader Joe's" }
        if header.lowercased().contains("whole") { return "Whole Foods Market" }
        if header.lowercased().contains("kroger") { return "Kroger" }
        if header.lowercased().contains("walmart") { return "Walmart" }
        if header.lowercased().contains("costco") { return "Costco" }
        if header.lowercased().contains("target") { return "Target" }
        if header.lowercased().contains("safeway") { return "Safeway" }
        if header.lowercased().contains("publix") { return "Publix" }
        if header.lowercased().contains("heb") { return "H-E-B" }
        return header.capitalized
    }
    
    private func extractPrice(from line: String) -> Double? {
        let pattern = "\\$?([0-9]+\\.[0-9]{2})"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return nil }
        let matches = regex.matches(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count))
        if let lastMatch = matches.last, let range = Range(lastMatch.range(at: 1), in: line) {
            return Double(line[range])
        }
        return nil
    }
    
    private func removePriceFromLine(_ line: String) -> String {
        let pattern = "\\$?([0-9]+\\.[0-9]{2})"
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return line }
        let range = NSRange(location: 0, length: line.utf16.count)
        return regex.stringByReplacingMatches(in: line, options: [], range: range, withTemplate: "")
    }
    
    private func extractQuantityAndUnitPrice(from line: String) -> (Double, Double?) {
        // e.g. "2.5LB @ 0.69/LB" or "2 @ 1.99"
        let pattern = "([0-9]+(\\.[0-9]+)?)\\s*@\\s*\\$?([0-9]+\\.[0-9]{2})"
        if let regex = try? NSRegularExpression(pattern: pattern),
           let match = regex.firstMatch(in: line, options: [], range: NSRange(location: 0, length: line.utf16.count)) {
            let qtyRange = Range(match.range(at: 1), in: line)
            let priceRange = Range(match.range(at: 3), in: line)
            
            let qty = qtyRange.flatMap { Double(line[$0]) } ?? 1.0
            let unitP = priceRange.flatMap { Double(line[$0]) }
            return (qty, unitP)
        }
        return (1.0, nil)
    }
    
    private func isHeaderFooterWord(_ text: String) -> Bool {
        let upper = text.uppercased()
        let words = ["SUBTOTAL", "TOTAL", "TAX", "VISA", "MASTERCARD", "CHANGE", "CASH", "BALANCE", "ITEM", "STORE", "THANK", "WELCOME"]
        return words.contains(where: { upper.contains($0) })
    }
}

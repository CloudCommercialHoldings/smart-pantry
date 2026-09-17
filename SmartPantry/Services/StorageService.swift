import Foundation

public class StorageService: ObservableObject {
    public static let shared = StorageService()
    
    @Published public var pantryItems: [PantryItem] = []
    @Published public var receipts: [ReceiptRecord] = []
    @Published public var ocrRules: [OCRCorrectionRule] = []
    @Published public var warranties: [WarrantyItem] = []
    
    private let pantryFilename = "pantry_items_v3.json"
    private let receiptsFilename = "receipt_records_v3.json"
    private let rulesFilename = "ocr_rules_v3.json"
    private let warrantiesFilename = "warranties_v3.json"
    
    public init() {
        loadAllData()
    }
    
    // MARK: - Data Persistence
    
    public func loadAllData() {
        self.pantryItems = load(filename: pantryFilename, as: [PantryItem].self) ?? []
        self.receipts = load(filename: receiptsFilename, as: [ReceiptRecord].self) ?? []
        self.ocrRules = load(filename: rulesFilename, as: [OCRCorrectionRule].self) ?? []
        self.warranties = load(filename: warrantiesFilename, as: [WarrantyItem].self) ?? []
        
        // Enforce Free Tier 20-Day Receipt Retention Auto-Purge
        enforceReceiptRetention()
        
        if pantryItems.isEmpty && receipts.isEmpty {
            seedSampleData()
        }
    }
    
    public func enforceReceiptRetention() {
        let result = SubscriptionService.shared.filterReceiptsForRetention(receipts)
        if result.purgedCount > 0 {
            self.receipts = result.valid
            saveReceipts()
        }
    }
    
    public func savePantryItems() {
        save(data: pantryItems, to: pantryFilename)
    }
    
    public func saveReceipts() {
        save(data: receipts, to: receiptsFilename)
    }
    
    public func saveOCRRules() {
        save(data: ocrRules, to: rulesFilename)
    }
    
    public func saveWarranties() {
        save(data: warranties, to: warrantiesFilename)
    }
    
    // MARK: - Pantry Operations
    
    public func addPantryItem(_ item: PantryItem) {
        pantryItems.append(item)
        savePantryItems()
        NotificationService.shared.scheduleNotifications(for: item)
    }
    
    public func updatePantryItem(_ item: PantryItem) {
        if let index = pantryItems.firstIndex(where: { $0.id == item.id }) {
            pantryItems[index] = item
            savePantryItems()
            NotificationService.shared.scheduleNotifications(for: item)
        }
    }
    
    public func deletePantryItem(_ item: PantryItem) {
        pantryItems.removeAll(where: { $0.id == item.id })
        savePantryItems()
        NotificationService.shared.cancelNotifications(for: item.id)
    }
    
    public func markAsConsumed(_ item: PantryItem) {
        if let index = pantryItems.firstIndex(where: { $0.id == item.id }) {
            pantryItems[index].isConsumed = true
            savePantryItems()
            NotificationService.shared.cancelNotifications(for: item.id)
        }
    }
    
    // MARK: - Warranty Operations
    
    public func addWarranty(_ item: WarrantyItem) {
        warranties.append(item)
        saveWarranties()
    }
    
    public func updateWarranty(_ item: WarrantyItem) {
        if let index = warranties.firstIndex(where: { $0.id == item.id }) {
            warranties[index] = item
            saveWarranties()
        }
    }
    
    public func deleteWarranty(_ item: WarrantyItem) {
        warranties.removeAll(where: { $0.id == item.id })
        saveWarranties()
    }
    
    // MARK: - Receipt History Operations
    
    public func addReceiptRecord(_ record: ReceiptRecord, importToPantry: Bool = true) {
        receipts.insert(record, at: 0)
        enforceReceiptRetention()
        saveReceipts()
        
        if importToPantry {
            for item in record.items {
                let metadata = ExpiryDatabaseService.shared.predictMetadata(itemName: item.normalizedName, location: item.suggestedLocation)
                let pantryItem = PantryItem(
                    name: item.normalizedName,
                    normalizedName: item.normalizedName,
                    category: item.category,
                    location: item.suggestedLocation,
                    quantity: item.quantity,
                    unit: "pcs",
                    purchasePrice: item.totalPrice,
                    purchaseDate: record.purchaseDate,
                    expirationDate: metadata.expirationDate,
                    receiptId: record.id
                )
                addPantryItem(pantryItem)
            }
        }
    }
    
    public func updateReceiptRecord(_ record: ReceiptRecord) {
        if let index = receipts.firstIndex(where: { $0.id == record.id }) {
            receipts[index] = record
            saveReceipts()
        }
    }
    
    public func deleteReceiptRecord(_ record: ReceiptRecord) {
        receipts.removeAll(where: { $0.id == record.id })
        saveReceipts()
    }
    
    // MARK: - Learned OCR Rules Operations
    
    public func addOrUpdateOCRRule(rawText: String, correctedName: String, category: ItemCategory, location: StorageLocation) {
        let cleanRaw = rawText.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if let index = ocrRules.firstIndex(where: { $0.originalRawText == cleanRaw }) {
            ocrRules[index].correctedName = correctedName
            ocrRules[index].correctedCategory = category
            ocrRules[index].correctedLocation = location
        } else {
            let rule = OCRCorrectionRule(originalRawText: cleanRaw, correctedName: correctedName, correctedCategory: category, correctedLocation: location)
            ocrRules.append(rule)
        }
        saveOCRRules()
    }
    
    // MARK: - Helper I/O
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func save<T: Encodable>(data: T, to filename: String) {
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            let encoded = try encoder.encode(data)
            try encoded.write(to: url, options: [.atomic, .completeFileProtection])
        } catch {
            print("Failed to save \(filename): \(error)")
        }
    }
    
    private func load<T: Decodable>(filename: String, as type: T.Type) -> T? {
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Failed to load \(filename): \(error)")
            return nil
        }
    }
    
    // MARK: - Seed Sample Data
    
    public func seedSampleData() {
        let calendar = Calendar.current
        let today = Date()
        
        let sampleItems: [PantryItem] = [
            PantryItem(
                name: "Organic Whole Milk",
                normalizedName: "Organic Whole Milk",
                category: .dairy,
                location: .fridge,
                quantity: 1,
                unit: "gal",
                purchasePrice: 4.29,
                purchaseDate: calendar.date(byAdding: .day, value: -3, to: today)!,
                expirationDate: calendar.date(byAdding: .day, value: 2, to: today)!
            ),
            PantryItem(
                name: "Boneless Chicken Breast",
                normalizedName: "Boneless Chicken Breast",
                category: .meatSeafood,
                location: .fridge,
                quantity: 1.5,
                unit: "lbs",
                purchasePrice: 6.99,
                purchaseDate: calendar.date(byAdding: .day, value: -2, to: today)!,
                expirationDate: calendar.date(byAdding: .day, value: 1, to: today)!
            ),
            PantryItem(
                name: "Fresh Strawberries",
                normalizedName: "Fresh Strawberries",
                category: .produce,
                location: .fridge,
                quantity: 1,
                unit: "lb",
                purchasePrice: 3.49,
                purchaseDate: calendar.date(byAdding: .day, value: -4, to: today)!,
                expirationDate: calendar.date(byAdding: .day, value: -1, to: today)!
            ),
            PantryItem(
                name: "Avocados 4-Pack",
                normalizedName: "Avocados 4-Pack",
                category: .produce,
                location: .pantry,
                quantity: 4,
                unit: "pcs",
                purchasePrice: 3.99,
                purchaseDate: calendar.date(byAdding: .day, value: -1, to: today)!,
                expirationDate: calendar.date(byAdding: .day, value: 4, to: today)!
            ),
            PantryItem(
                name: "Pasture Raised Eggs",
                normalizedName: "Pasture Raised Eggs",
                category: .dairy,
                location: .fridge,
                quantity: 12,
                unit: "ct",
                purchasePrice: 4.99,
                purchaseDate: calendar.date(byAdding: .day, value: -5, to: today)!,
                expirationDate: calendar.date(byAdding: .day, value: 16, to: today)!
            ),
            PantryItem(
                name: "Artisan Sourdough Bread",
                normalizedName: "Artisan Sourdough Bread",
                category: .bakery,
                location: .pantry,
                quantity: 1,
                unit: "loaf",
                purchasePrice: 4.49,
                purchaseDate: calendar.date(byAdding: .day, value: -2, to: today)!,
                expirationDate: calendar.date(byAdding: .day, value: 3, to: today)!
            )
        ]
        
        self.pantryItems = sampleItems
        savePantryItems()
        
        // Seed Receipt History
        let sampleLines = ReceiptOCRService.shared.getSampleReceiptLines(for: "Trader Joe's")
        let sampleReceipt = ReceiptParserEngine.shared.parse(lines: sampleLines)
        self.receipts = [sampleReceipt]
        saveReceipts()
        
        // Seed Warranties
        let sampleWarranty = WarrantyItem(
            title: "Ninja Air Fryer Pro 4-in-1",
            storeName: "Target",
            purchaseDate: calendar.date(byAdding: .month, value: -3, to: today)!,
            warrantyMonths: 24,
            claimNotes: "Model AF101 - Keep receipt for 2 year manufacturer warranty."
        )
        self.warranties = [sampleWarranty]
        saveWarranties()
    }
}

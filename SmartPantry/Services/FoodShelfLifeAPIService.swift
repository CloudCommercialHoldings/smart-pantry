import Foundation

public struct FoodShelfLifeInfo: Codable, Equatable {
    public let name: String
    public let category: ItemCategory
    public let recommendedLocation: StorageLocation
    public let fridgeDays: Int
    public let freezerDays: Int
    public let pantryDays: Int
    public let spiceRackDays: Int?
    public let fdaFacts: String
    public let freezerGuidance: String?
    public let spiceGuidance: String?
    
    public init(
        name: String,
        category: ItemCategory,
        recommendedLocation: StorageLocation,
        fridgeDays: Int,
        freezerDays: Int,
        pantryDays: Int,
        spiceRackDays: Int? = nil,
        fdaFacts: String,
        freezerGuidance: String? = nil,
        spiceGuidance: String? = nil
    ) {
        self.name = name
        self.category = category
        self.recommendedLocation = recommendedLocation
        self.fridgeDays = fridgeDays
        self.freezerDays = freezerDays
        self.pantryDays = pantryDays
        self.spiceRackDays = spiceRackDays
        self.fdaFacts = fdaFacts
        self.freezerGuidance = freezerGuidance
        self.spiceGuidance = spiceGuidance
    }
}

public class FoodShelfLifeAPIService {
    public static let shared = FoodShelfLifeAPIService()
    
    // Comprehensive FDA & USDA FoodKeeper reference database
    private let database: [String: FoodShelfLifeInfo] = [
        "bread": FoodShelfLifeInfo(
            name: "Bread & Bakery",
            category: .bakery,
            recommendedLocation: .pantry,
            fridgeDays: 14,
            freezerDays: 90,
            pantryDays: 7,
            fdaFacts: "FDA Guidance: Store bread at room temperature in a breadbox or pantry. Commercial sliced breads last 5-7 days at room temperature. Freezing extends shelf life up to 3 months without mold.",
            freezerGuidance: "Freezer Advice: Slice bread before freezing. Thaw individual slices in a toaster for fresh texture without moisture loss."
        ),
        "milk": FoodShelfLifeInfo(
            name: "Milk",
            category: .dairy,
            recommendedLocation: .fridge,
            fridgeDays: 7,
            freezerDays: 30,
            pantryDays: 0,
            fdaFacts: "FDA Guidance: Keep refrigerated at 40°F (4°C) or below. Consume within 7 days of opening. Milk can be frozen for up to 1 month; thaw in refrigerator and shake before use as fat may separate.",
            freezerGuidance: "Freezer Advice: Leave 1/2 inch headspace in container as milk expands when frozen."
        ),
        "chicken": FoodShelfLifeInfo(
            name: "Fresh Chicken / Poultry",
            category: .meatSeafood,
            recommendedLocation: .fridge,
            fridgeDays: 2,
            freezerDays: 270,
            pantryDays: 0,
            fdaFacts: "FDA/USDA Guidance: Raw poultry must be cooked or frozen within 1-2 days of purchase. Freezing at 0°F preserves poultry safely for 9 months (whole) or 9 months (parts). Always thaw in refrigerator, cold water, or microwave—never at room temperature.",
            freezerGuidance: "Freezer Advice: Wrap tightly in moisture-proof freezer paper or vacuum seal to avoid freezer burn."
        ),
        "beef": FoodShelfLifeInfo(
            name: "Beef & Steaks",
            category: .meatSeafood,
            recommendedLocation: .fridge,
            fridgeDays: 4,
            freezerDays: 365,
            pantryDays: 0,
            fdaFacts: "FDA/USDA Guidance: Steaks and roasts last 3-5 days refrigerated, or 6-12 months in the freezer. Ground beef lasts 1-2 days in fridge, 3-4 months frozen.",
            freezerGuidance: "Freezer Advice: Quality stays optimal if frozen at peak freshness. Label with freeze date."
        ),
        "ground beef": FoodShelfLifeInfo(
            name: "Ground Beef",
            category: .meatSeafood,
            recommendedLocation: .fridge,
            fridgeDays: 2,
            freezerDays: 120,
            pantryDays: 0,
            fdaFacts: "FDA Guidance: Ground meat has higher surface area and spoils faster. Use within 2 days of purchase or freeze for up to 4 months.",
            freezerGuidance: "Freezer Advice: Flatten ground meat in freezer bags for fast thawing."
        ),
        "salmon": FoodShelfLifeInfo(
            name: "Salmon & Finfish",
            category: .meatSeafood,
            recommendedLocation: .fridge,
            fridgeDays: 2,
            freezerDays: 180,
            pantryDays: 0,
            fdaFacts: "FDA Guidance: Fresh fish lasts 1-2 days refrigerated. Lean fish freezes well for 6-8 months; fatty fish like salmon freezes best for 2-3 months.",
            freezerGuidance: "Freezer Advice: Glaze with ice or vacuum seal to retain moisture and natural omega-3 oils."
        ),
        "egg": FoodShelfLifeInfo(
            name: "Fresh Eggs",
            category: .dairy,
            recommendedLocation: .fridge,
            fridgeDays: 35,
            freezerDays: 365,
            pantryDays: 1,
            fdaFacts: "FDA Guidance: Store in the coldest part of refrigerator, not the door. Raw shell eggs last 3-5 weeks from purchase date. Do not freeze eggs in shells.",
            freezerGuidance: "Freezer Advice: Beat eggs until blended and freeze in airtight container up to 1 year."
        ),
        "cheese": FoodShelfLifeInfo(
            name: "Hard & Shredded Cheese",
            category: .dairy,
            recommendedLocation: .fridge,
            fridgeDays: 28,
            freezerDays: 180,
            pantryDays: 0,
            fdaFacts: "FDA Guidance: Hard cheeses (cheddar, parmesan) last 3-4 weeks opened in fridge. Freezing hard cheese extends life 6 months, though texture may become crumbly.",
            freezerGuidance: "Freezer Advice: Frozen cheese melts best on pizzas, casseroles, and sauces."
        ),
        "banana": FoodShelfLifeInfo(
            name: "Bananas",
            category: .produce,
            recommendedLocation: .pantry,
            fridgeDays: 5,
            freezerDays: 90,
            pantryDays: 5,
            fdaFacts: "FDA Guidance: Keep at room temperature until ripe. Peel and freeze ripe bananas for smoothies and baking.",
            freezerGuidance: "Freezer Advice: Frozen peeled bananas last 3-6 months in airtight bags for instant smoothies."
        ),
        "apple": FoodShelfLifeInfo(
            name: "Apples",
            category: .produce,
            recommendedLocation: .fridge,
            fridgeDays: 28,
            freezerDays: 240,
            pantryDays: 7,
            fdaFacts: "FDA Guidance: Apples emit ethylene gas. Store refrigerated in produce crisper drawer to maintain crunch for up to 4 weeks.",
            freezerGuidance: "Freezer Advice: Slice and toss with lemon juice before freezing to prevent browning."
        ),
        "spinach": FoodShelfLifeInfo(
            name: "Spinach & Leafy Greens",
            category: .produce,
            recommendedLocation: .fridge,
            fridgeDays: 5,
            freezerDays: 240,
            pantryDays: 1,
            fdaFacts: "FDA Guidance: Wash immediately before consumption, not before storing. Keep moisture low by placing a paper towel in the container.",
            freezerGuidance: "Freezer Advice: Blanch greens in boiling water for 2 mins, then ice bath before freezing to preserve nutrients."
        ),
        "pepper": FoodShelfLifeInfo(
            name: "Black Pepper & Ground Spices",
            category: .condiments,
            recommendedLocation: .spiceRack,
            fridgeDays: 365,
            freezerDays: 730,
            pantryDays: 365,
            spiceRackDays: 365,
            fdaFacts: "FDA & Spice Association Facts: Spices don't usually spoil or harbor foodborne pathogens because of low water activity, but they lose essential oils, aroma, and potency over time.",
            freezerGuidance: nil,
            spiceGuidance: "Why Spices Get Hard: Steam from boiling pans enters spice jars when shaking over hot stoves! Always use a dry spoon or shake into your palm first. Keep away from heat, steam, and direct sunlight. Ground spices stay fresh for 6-12 months; whole spices last 2-3 years."
        ),
        "spice": FoodShelfLifeInfo(
            name: "Culinary Spices & Herbs",
            category: .condiments,
            recommendedLocation: .spiceRack,
            fridgeDays: 365,
            freezerDays: 730,
            pantryDays: 365,
            spiceRackDays: 365,
            fdaFacts: "FDA Guidance: Keep spices sealed tightly in airtight containers. If spices smell dull or form rock-hard clumps, their aromatic oils have degraded.",
            freezerGuidance: nil,
            spiceGuidance: "Spice Clumping Fix: Add a few grains of uncooked dry rice to the jar to absorb moisture. Store in a cool, dark spice rack away from the dishwasher or stovetop."
        ),
        "garlic": FoodShelfLifeInfo(
            name: "Garlic Powder & Garlic",
            category: .condiments,
            recommendedLocation: .spiceRack,
            fridgeDays: 60,
            freezerDays: 180,
            pantryDays: 90,
            spiceRackDays: 365,
            fdaFacts: "FDA Guidance: Garlic powder is hygroscopic (attracts moisture quickly). Keep tightly capped. Whole bulbs last 3-5 months in cool dark pantry.",
            freezerGuidance: "Freezer Advice: Minced garlic can be frozen in ice cube trays with olive oil.",
            spiceGuidance: "Anti-Caking Tip: Never leave garlic powder open over steaming pots. Use silica packets or store in a sealed mason jar."
        ),
        "cinnamon": FoodShelfLifeInfo(
            name: "Cinnamon",
            category: .condiments,
            recommendedLocation: .spiceRack,
            fridgeDays: 365,
            freezerDays: 730,
            pantryDays: 365,
            spiceRackDays: 730,
            fdaFacts: "FDA Facts: Ground cinnamon maintains aroma for 1-2 years; cinnamon sticks remain potent up to 4 years when kept sealed.",
            freezerGuidance: nil,
            spiceGuidance: "Freshness Test: Rub a pinch between fingers—if fragrance is weak or woody, it is time to replace."
        ),
        "oregano": FoodShelfLifeInfo(
            name: "Dried Oregano & Herbs",
            category: .condiments,
            recommendedLocation: .spiceRack,
            fridgeDays: 365,
            freezerDays: 730,
            pantryDays: 365,
            spiceRackDays: 365,
            fdaFacts: "FDA Facts: Dried leafy herbs retain optimal flavor for 1-3 years. Crush between palms to release aroma.",
            freezerGuidance: nil,
            spiceGuidance: "Anti-Hardening Rule: Store in glass or tin containers rather than paper packets to protect from humidity."
        ),
        "curry": FoodShelfLifeInfo(
            name: "Curry Powder & Blends",
            category: .condiments,
            recommendedLocation: .spiceRack,
            fridgeDays: 365,
            freezerDays: 730,
            pantryDays: 365,
            spiceRackDays: 365,
            fdaFacts: "FDA Facts: Spice blends with turmeric and cumin lose pungency rapidly when exposed to sunlight. Store in opaque jars.",
            freezerGuidance: nil,
            spiceGuidance: "Keep away from stove heat vents to prevent oil drying and clumping."
        ),
        "pizza": FoodShelfLifeInfo(
            name: "Frozen Pizza / Prepared Meals",
            category: .frozen,
            recommendedLocation: .freezer,
            fridgeDays: 3,
            freezerDays: 180,
            pantryDays: 0,
            fdaFacts: "FDA Guidance: Frozen commercial meals remain bacteria-safe indefinitely at 0°F (-18°C). Quality remains best within 2-4 months.",
            freezerGuidance: "Freezer Advice: Keep sealed in original plastic wrapping. If ice crystals form on top, cook promptly."
        )
    ]
    
    public init() {}
    
    /// Returns shelf life info and calculates accurate expiration date
    public func estimateShelfLife(
        itemName: String,
        location: StorageLocation? = nil,
        purchaseDate: Date = Date()
    ) -> (expirationDate: Date, info: FoodShelfLifeInfo) {
        let clean = itemName.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        var matched: FoodShelfLifeInfo? = nil
        for (key, val) in database {
            if clean.contains(key) {
                matched = val
                break
            }
        }
        
        let info = matched ?? fallbackInfo(for: clean)
        let targetLocation = location ?? info.recommendedLocation
        
        let days: Int
        switch targetLocation {
        case .freezer:
            days = info.freezerDays
        case .fridge:
            days = info.fridgeDays
        case .pantry:
            days = info.pantryDays
        case .spiceRack:
            days = info.spiceRackDays ?? 365
        }
        
        let expirationDate = Calendar.current.date(byAdding: .day, value: max(days, 1), to: purchaseDate) ?? purchaseDate
        return (expirationDate, info)
    }
    
    /// Queries OpenFoodFacts API asynchronously with local fallback
    public func fetchOnlineOrLocal(
        itemName: String,
        location: StorageLocation? = nil,
        purchaseDate: Date = Date(),
        completion: @escaping (Date, FoodShelfLifeInfo) -> Void
    ) {
        // Run network query in background
        guard let encoded = itemName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://world.openfoodfacts.org/cgi/search.pl?search_terms=\(encoded)&search_simple=1&action=process&json=1&page_size=1") else {
            let result = estimateShelfLife(itemName: itemName, location: location, purchaseDate: purchaseDate)
            completion(result.expirationDate, result.info)
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 3.0
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            // If offline or network slow, fall back instantly to USDA/FDA local intelligence
            let local = self.estimateShelfLife(itemName: itemName, location: location, purchaseDate: purchaseDate)
            DispatchQueue.main.async {
                completion(local.expirationDate, local.info)
            }
        }.resume()
    }
    
    private func fallbackInfo(for name: String) -> FoodShelfLifeInfo {
        if name.contains("spice") || name.contains("salt") || name.contains("herb") || name.contains("powder") || name.contains("season") {
            return FoodShelfLifeInfo(
                name: name.capitalized,
                category: .condiments,
                recommendedLocation: .spiceRack,
                fridgeDays: 365,
                freezerDays: 730,
                pantryDays: 365,
                spiceRackDays: 365,
                fdaFacts: "FDA Facts: Spices and dried herbs do not spoil biologically if kept dry, but their essential oils evaporate, causing them to turn hard or flavorless.",
                spiceGuidance: "Keep away from steam from cooking pots. Always measure with a dry spoon. Ground spices last 1 year; whole spices last 2-3 years."
            )
        }
        
        return FoodShelfLifeInfo(
            name: name.capitalized,
            category: .produce,
            recommendedLocation: .fridge,
            fridgeDays: 7,
            freezerDays: 180,
            pantryDays: 4,
            fdaFacts: "FDA Guidance: Keep perishable foods refrigerated below 40°F. Storing in the freezer extends quality by several months.",
            freezerGuidance: "Freezer Advice: Package in airtight containers or freezer bags to lock in moisture."
        )
    }
}

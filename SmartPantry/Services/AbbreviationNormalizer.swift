import Foundation

public class AbbreviationNormalizer {
    public static let shared = AbbreviationNormalizer()
    
    private var dictionary: [String: String] = [
        // Produce Shorthand
        "ORG": "Organic",
        "OG": "Organic",
        "AVO": "Avocado",
        "AVOC": "Avocado",
        "BAN": "Banana",
        "BANANAS": "Bananas",
        "APL": "Apple",
        "STRW": "Strawberries",
        "STRAWBRY": "Strawberry",
        "BLU": "Blueberries",
        "RASP": "Raspberries",
        "BLBERRY": "Blueberries",
        "SPN": "Spinach",
        "SPNCH": "Spinach",
        "KLE": "Kale",
        "LETT": "Lettuce",
        "ROM": "Romaine Lettuce",
        "TOM": "Tomatoes",
        "TOMATO": "Tomato",
        "POT": "Potatoes",
        "ONN": "Onion",
        "ONION": "Onion",
        "YEL": "Yellow",
        "RED": "Red",
        "WHT": "White",
        "GRLC": "Garlic",
        "CAR": "Carrots",
        "CARROT": "Carrot",
        "CUC": "Cucumber",
        "CEL": "Celery",
        "BROC": "Broccoli",
        "CAUL": "Cauliflower",
        "LEM": "Lemon",
        "LIM": "Lime",
        
        // Meat & Seafood Shorthand
        "BNLS": "Boneless",
        "SKNLS": "Skinless",
        "CHKN": "Chicken",
        "CHK": "Chicken",
        "BRST": "Breast",
        "THIGH": "Thighs",
        "TNDR": "Tenders",
        "BEEF": "Beef",
        "GRND": "Ground",
        "GND": "Ground",
        "GRS": "Grass Fed",
        "FED": "Fed",
        "PRK": "Pork",
        "CHP": "Chops",
        "SLMN": "Salmon",
        "SHMP": "Shrimp",
        "TNA": "Tuna",
        "STK": "Steak",
        "RIBY": "Ribeye",
        "TURK": "Turkey",
        "BACON": "Bacon",
        "BCN": "Bacon",
        "SAUS": "Sausage",
        
        // Dairy & Bakery
        "WHL": "Whole",
        "MLK": "Milk",
        "OAT": "Oat Milk",
        "ALMD": "Almond Milk",
        "SOY": "Soy Milk",
        "PAS": "Pasture Raised",
        "FREE": "Free Range",
        "EGGS": "Eggs",
        "EGG": "Egg",
        "CHZ": "Cheese",
        "CHED": "Cheddar",
        "MOZZ": "Mozzarella",
        "PARM": "Parmesan",
        "YOG": "Yogurt",
        "GRK": "Greek Yogurt",
        "BUTTR": "Butter",
        "BTR": "Butter",
        "CRM": "Cream",
        "SOUR": "Sour Cream",
        "BRD": "Bread",
        "WHT BRD": "White Bread",
        "WHL WHT": "Whole Wheat",
        "BAGEL": "Bagels",
        "CROISS": "Croissant",
        
        // Quantities & Units
        "1GAL": "1 Gallon",
        "GAL": "Gallon",
        "HALF": "Half Gallon",
        "12CT": "12 Count",
        "6CT": "6 Count",
        "4PK": "4 Pack",
        "6PK": "6 Pack",
        "12PK": "12 Pack",
        "LB": "lb",
        "LBS": "lbs",
        "OZ": "oz",
        "CT": "Count",
        "PK": "Pack",
        "BTL": "Bottle",
        "CAN": "Can"
    ]
    
    public init() {}
    
    /// Normalizes a raw receipt text string by expanding common abbreviations and cleaning formatting
    public func normalize(_ rawText: String) -> String {
        // Strip receipt code numbers at start if any (e.g. "042918 ORG BNLS CHKN $5.99" -> "ORG BNLS CHKN $5.99")
        var text = rawText
        let regexCode = try? NSRegularExpression(pattern: "^[0-9]{4,12}\\s+", options: [])
        if let regexCode = regexCode {
            let range = NSRange(location: 0, length: text.utf16.count)
            text = regexCode.stringByReplacingMatches(in: text, options: [], range: range, withTemplate: "")
        }
        
        // Split by whitespace
        let tokens = text.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        var resultTokens: [String] = []
        
        for token in tokens {
            let cleanToken = token.trimmingCharacters(in: CharacterSet.alphanumerics.inverted).uppercased()
            if let expanded = dictionary[cleanToken] {
                resultTokens.append(expanded)
            } else if cleanToken.count > 1 {
                // Capitalize token nicely
                resultTokens.append(token.capitalized)
            } else if !token.isEmpty {
                resultTokens.append(token)
            }
        }
        
        let result = resultTokens.joined(separator: " ")
        return result.isEmpty ? rawText.capitalized : result
    }
}

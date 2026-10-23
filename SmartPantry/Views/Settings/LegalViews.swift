import SwiftUI

public enum LegalDocument: String, Identifiable {
    case privacy
    case terms
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .privacy: return "Privacy Policy"
        case .terms: return "Terms of Use"
        }
    }
}

public struct LegalDocumentView: View {
    let document: LegalDocument
    @Environment(\.dismiss) private var dismiss
    
    public init(document: LegalDocument) {
        self.document = document
    }
    
    public var body: some View {
        ScrollView {
            Text(bodyText)
                .font(.body)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
        }
        .background { KitchenCanvas() }
        .kitchenChrome()
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
    
    private var bodyText: String {
        switch document {
        case .privacy: return LegalCopy.privacyPolicy
        case .terms: return LegalCopy.termsOfUse
        }
    }
}

public enum LegalCopy {
    public static let privacyPolicy = """
    Last updated: October 23, 2026

    Intelligent Living Pantry (“we”, “the app”) is a pantry, receipt, and expiration tracker.

    Information stored on this device
    • When Amazon Cognito is configured, your email and password are sent to your Cognito User Pool to create and sign in to an account. Tokens stay in the iOS Keychain on this device.
    • If Cognito is not configured, account name, email, and a password verifier stay only on this iPhone or iPad.
    • Pantry items, receipts, warranties, photos you attach, and notification preferences stay on this device unless you later enable cloud sync.
    • We do not sell personal data.

    Camera and photos
    Camera and photo library access are used only when you scan receipts, photograph pantry or fridge shelves, or attach item photos. Images are processed on device for text recognition.

    Network requests
    Intelligent Living Pantry may load catalog food photographs from Unsplash (images.unsplash.com) so shelves look realistic. Those requests use hardcoded photo URLs, not your grocery list. Shelf-life estimates use an on-device USDA/FDA reference and do not send item names to third parties. Sign-in may contact Amazon Cognito (cognito-idp in your chosen AWS region). If you continue with Apple, Google, or Facebook, Cognito receives an account token from that provider so we can create or open your app account. We do not post to your social accounts. Subscriptions are processed by Apple.

    Location
    If you allow location, Intelligent Living Pantry uses it only while the app is open to search Apple Maps for nearby stores that match foods you log often. We keep a neighborhood name for those suggestions. We do not store a location history or sell your location.

    Notifications
    Local notifications remind you about expiration dates without naming the food on the lock screen. A separate weekly and midweek alert can name a food you log often and a nearby store type, such as bakeries when you stock bread. Turn alerts off in iOS Settings.

    Purchases
    Subscriptions are processed by Apple. We do not receive your full payment card details. Pro status is confirmed with StoreKit and is not stored as a trusted flag on the device.

    Data retention and deletion
    You can sign out or delete your in-app account at any time in Settings. Deleting your account removes the local login, pantry items, receipts, warranties, image cache, export files, and related preferences on this device. This cannot be undone. You can also delete the app to remove remaining on-device data.

    Contact
    \(ProductionConfig.supportEmail)
    """
    
    public static let termsOfUse = """
    Last updated: October 23, 2026

    By using Intelligent Living Pantry you agree to these Terms of Use.

    The app
    Intelligent Living Pantry helps you log groceries, scan receipts, track expiration, and optionally subscribe to Pro features. Shelf-life guidance is informational and is not medical, safety, or tax advice.

    Accounts
    You are responsible for the information you enter. Do not use another person’s email without permission. When Amazon Cognito is enabled, authentication is provided by AWS Cognito in your configured region.

    Subscriptions
    Intelligent Living Pantry Pro is an auto-renewing subscription sold through Apple. Prices are shown in the paywall and charged to your Apple ID. Payment is charged at confirmation of purchase. Subscriptions renew unless canceled at least 24 hours before the end of the current period. Manage or cancel in iPhone Settings → Apple ID → Subscriptions. Unused portions of a free trial are forfeited when you purchase.

    Acceptable use
    Do not use the app to store illegal content or to misrepresent purchases.

    Disclaimer
    The app is provided “as is”. Expiration estimates, OCR results, and reports may be incomplete. Always use your own judgment with food safety and taxes.

    Contact
    \(ProductionConfig.supportEmail)
    """
}

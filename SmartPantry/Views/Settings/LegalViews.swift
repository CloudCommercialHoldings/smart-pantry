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
    @Environment(\.presentationMode) var presentationMode
    
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
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { presentationMode.wrappedValue.dismiss() }
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
    Last updated: September 26, 2026

    Smart Pantry (“we”, “the app”) is a pantry, receipt, and expiration tracker.

    Information we collect
    • Account details you enter (name, email, password) are stored only on this device.
    • Pantry items, receipts, warranties, photos you attach, and notification preferences stay on this device.
    • We do not operate a cloud account server and do not sell personal data.

    Camera and photos
    Camera and photo library access are used only when you scan receipts, read barcodes, or attach item photos. Images are processed on device for text recognition.

    Notifications
    Local notifications remind you about expiration dates. You can disable them in iOS Settings.

    Purchases
    Subscriptions are processed by Apple. We do not receive your full payment card details.

    Data retention and deletion
    You can sign out or delete your in-app account at any time in Settings. Deleting your account removes the local login record. You can also delete the app to remove remaining on-device data.

    Contact
    support@smartpantry.app
    """
    
    public static let termsOfUse = """
    Last updated: September 26, 2026

    By using Smart Pantry you agree to these Terms of Use.

    The app
    Smart Pantry helps you log groceries, scan receipts, track expiration, and optionally subscribe to Pro features. Shelf-life guidance is informational and is not medical, safety, or tax advice.

    Accounts
    You are responsible for the information you enter. Do not use another person’s email without permission.

    Subscriptions
    Smart Pantry Pro is an auto-renewing subscription sold through Apple. Prices are shown in the paywall and charged to your Apple ID. Payment is charged at confirmation of purchase. Subscriptions renew unless canceled at least 24 hours before the end of the current period. Manage or cancel in iPhone Settings → Apple ID → Subscriptions. Unused portions of a free trial are forfeited when you purchase.

    Acceptable use
    Do not use the app to store illegal content or to misrepresent purchases.

    Disclaimer
    The app is provided “as is”. Expiration estimates, OCR results, and reports may be incomplete. Always use your own judgment with food safety and taxes.

    Contact
    support@smartpantry.app
    """
}

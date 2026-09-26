import SwiftUI

public struct SettingsView: View {
    @ObservedObject var auth = AuthService.shared
    @ObservedObject var sub = SubscriptionService.shared
    @ObservedObject var storage = StorageService.shared
    
    @State private var showPaywall = false
    @State private var showSignOut = false
    @State private var showDeleteAccount = false
    @State private var legalDocument: LegalDocument?
    @State private var showRestoreResult = false
    @State private var restoreSucceeded = false
    @State private var exportItems: [Any] = []
    @State private var showExportSheet = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            List {
                Section("Account") {
                    HStack {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(auth.currentUser?.name.isEmpty == false ? auth.currentUser!.name : "Guest")
                                .font(.headline)
                            Text(auth.isGuest ? "Using Smart Pantry on this device" : (auth.currentUser?.email ?? ""))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button("Sign Out", role: .destructive) {
                        showSignOut = true
                    }
                    
                    Button("Delete Account & Data", role: .destructive) {
                        showDeleteAccount = true
                    }
                }
                
                Section("Smart Pantry Pro") {
                    HStack {
                        Text("Status")
                        Spacer()
                        Text(sub.isPro ? "Pro" : "Free")
                            .foregroundColor(sub.isPro ? .purple : .secondary)
                            .fontWeight(.semibold)
                    }
                    
                    if !sub.isPro {
                        Button("Upgrade to Pro") { showPaywall = true }
                    } else {
                        Button("Manage Subscription") { sub.manageSubscriptions() }
                    }
                    
                    Button("Restore Purchases") {
                        sub.restorePurchases { success in
                            restoreSucceeded = success
                            showRestoreResult = true
                        }
                    }
                }
                
                Section("Your Data") {
                    Button("Export Pantry & Receipts") {
                        let csv = storage.exportPersonalDataCSV()
                        let url = FileManager.default.temporaryDirectory.appendingPathComponent("SmartPantry-Export.csv")
                        try? csv.data(using: .utf8)?.write(to: url)
                        exportItems = [url]
                        showExportSheet = true
                    }
                    Text("Smart Pantry stores your account, pantry, and receipts on this device. Export a copy or delete everything below.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Notifications") {
                    Button("Open Notification Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    Text("Smart Pantry uses local alerts for food that is expiring soon. You can turn these off in iOS Settings.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Legal") {
                    Button("Privacy Policy") { legalDocument = .privacy }
                    Button("Terms of Use") { legalDocument = .terms }
                    Link("Contact Support", destination: URL(string: "mailto:support@smartpantry.app?subject=Smart%20Pantry%20Support")!)
                }
                
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                    Text("Receipt scanning, expiration estimates, and reports are for personal organization. They are not food-safety or tax advice.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) { PaywallView() }
            .sheet(item: $legalDocument) { doc in
                NavigationView { LegalDocumentView(document: doc) }
            }
            .alert("Sign Out", isPresented: $showSignOut) {
                Button("Sign Out", role: .destructive) { auth.signOut() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("You can sign back in on this device. Pantry data stays on the phone until you delete the app or your account.")
            }
            .alert("Delete Account", isPresented: $showDeleteAccount) {
                Button(auth.isGuest ? "Delete Data" : "Delete Account", role: .destructive) {
                    auth.deleteAccount()
                    storage.wipeAllUserData()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This removes your local Smart Pantry login, pantry items, receipts, and warranties stored on this device. This cannot be undone.")
            }
            .sheet(isPresented: $showExportSheet) {
                ActivityShareView(items: exportItems)
            }
            .alert(restoreSucceeded ? "Purchases Restored" : "No Purchase Found", isPresented: $showRestoreResult) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(restoreSucceeded
                     ? "Your Pro subscription is active."
                     : "We could not find an Apple ID purchase for Smart Pantry Pro.")
            }
        }
        .navigationViewStyle(.stack)
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

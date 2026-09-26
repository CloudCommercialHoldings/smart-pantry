import SwiftUI

public struct MainTabView: View {
    @StateObject private var storage = StorageService.shared
    @State private var selectedTab: Int = 0
    @State private var showNotificationPrompt = false
    
    public init() {}
    
    public var expiringBadgeCount: Int {
        storage.pantryItems.filter { !$0.isConsumed && ($0.expiryStatus == .expiringSoon || $0.expiryStatus == .expired) }.count
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            PantryListView()
                .tabItem {
                    Label("Pantry", systemImage: "cabinet.fill")
                }
                .badge(expiringBadgeCount > 0 ? expiringBadgeCount : 0)
                .tag(0)
            
            ScannerSelectionView()
                .tabItem {
                    Label("Scanner", systemImage: "doc.viewfinder.fill")
                }
                .tag(1)
            
            ReceiptHistoryView()
                .tabItem {
                    Label("Receipts", systemImage: "doc.text.fill")
                }
                .tag(2)
            
            SpendingAnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(3)
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .onAppear {
            if !UserDefaults.standard.bool(forKey: "did_ask_notifications") {
                showNotificationPrompt = true
            }
        }
        .alert("Expiration Reminders", isPresented: $showNotificationPrompt) {
            Button("Enable Reminders") {
                UserDefaults.standard.set(true, forKey: "did_ask_notifications")
                NotificationService.shared.requestAuthorization()
            }
            Button("Not Now", role: .cancel) {
                UserDefaults.standard.set(true, forKey: "did_ask_notifications")
            }
        } message: {
            Text("Smart Pantry can send on-device alerts when food is about to expire. We do not send marketing notifications.")
        }
    }
}

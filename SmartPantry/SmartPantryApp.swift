import SwiftUI

@main
struct SmartPantryApp: App {
    @StateObject private var authService = AuthService.shared
    @StateObject private var subscriptionService = SubscriptionService.shared
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authService.isLoggedIn {
                    MainTabView()
                } else {
                    AuthOnboardingView()
                }
            }
            .task {
                await subscriptionService.start()
            }
        }
    }
}

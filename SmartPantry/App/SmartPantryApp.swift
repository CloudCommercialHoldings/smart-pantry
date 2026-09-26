import SwiftUI

@main
struct SmartPantryApp: App {
    @StateObject private var authService = AuthService.shared
    
    var body: some Scene {
        WindowGroup {
            if authService.isLoggedIn {
                MainTabView()
            } else {
                AuthOnboardingView()
            }
        }
    }
}

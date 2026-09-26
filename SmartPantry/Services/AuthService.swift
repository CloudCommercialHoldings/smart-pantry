import Foundation
import SwiftUI
import Combine
import CryptoKit

public struct UserProfile: Codable, Equatable {
    public var email: String
    public var name: String
    public var createdAt: Date
    
    public init(email: String, name: String, createdAt: Date = Date()) {
        self.email = email
        self.name = name
        self.createdAt = createdAt
    }
}

public class AuthService: ObservableObject {
    public static let shared = AuthService()
    
    @Published public var isLoggedIn: Bool = false
    @Published public var currentUser: UserProfile? = nil
    @Published public var authErrorMessage: String? = nil
    
    private let userDefaultsKey = "smartpantry_current_user"
    private let loggedInKey = "smartpantry_is_logged_in"
    private let usersDatabaseKey = "smartpantry_registered_users"
    
    public var isGuest: Bool {
        guard isLoggedIn else { return false }
        return (currentUser?.email ?? "").isEmpty
    }
    
    public init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: loggedInKey)
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.currentUser = user
        }
    }
    
    public func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,64}$"#
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: email.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    public func isValidPassword(_ password: String) -> (isValid: Bool, message: String?) {
        if password.count < 6 {
            return (false, "Password must be at least 6 characters.")
        }
        return (true, nil)
    }
    
    public func signUp(email: String, password: String, name: String) -> Bool {
        authErrorMessage = nil
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard isValidEmail(cleanEmail) else {
            authErrorMessage = "Please enter a valid email address."
            return false
        }
        
        let passwordCheck = isValidPassword(password)
        guard passwordCheck.isValid else {
            authErrorMessage = passwordCheck.message
            return false
        }
        
        var registered = getRegisteredUsers()
        if registered[cleanEmail] != nil {
            authErrorMessage = "An account with this email already exists. Please sign in."
            return false
        }
        
        registered[cleanEmail] = hashedPassword(password)
        saveRegisteredUsers(registered)
        
        let displayName = cleanName.isEmpty ? cleanEmail.components(separatedBy: "@").first?.capitalized ?? "Chef" : cleanName
        let user = UserProfile(email: cleanEmail, name: displayName)
        setCurrentUser(user)
        return true
    }
    
    public func signIn(email: String, password: String) -> Bool {
        authErrorMessage = nil
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        guard isValidEmail(cleanEmail) else {
            authErrorMessage = "Please enter a valid email address."
            return false
        }
        
        guard !password.isEmpty else {
            authErrorMessage = "Please enter your password."
            return false
        }
        
        let registered = getRegisteredUsers()
        guard let storedPassword = registered[cleanEmail] else {
            authErrorMessage = "No account found for this email. Create an account or continue as guest."
            return false
        }
        
        if passwordsMatch(password, stored: storedPassword) {
            var updated = registered
            if storedPassword != hashedPassword(password) {
                updated[cleanEmail] = hashedPassword(password)
                saveRegisteredUsers(updated)
            }
            let displayName = cleanEmail.components(separatedBy: "@").first?.capitalized ?? "Chef"
            let user = UserProfile(email: cleanEmail, name: displayName)
            setCurrentUser(user)
            return true
        }
        
        authErrorMessage = "Incorrect password. Please try again."
        return false
    }
    
    public func continueAsGuest() {
        authErrorMessage = nil
        setCurrentUser(UserProfile(email: "", name: "Guest"))
    }
    
    public func signOut() {
        self.isLoggedIn = false
        self.currentUser = nil
        UserDefaults.standard.set(false, forKey: loggedInKey)
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    public func deleteAccount() {
        if let email = currentUser?.email.lowercased(), !email.isEmpty {
            var registered = getRegisteredUsers()
            registered.removeValue(forKey: email)
            saveRegisteredUsers(registered)
        }
        signOut()
    }
    
    private func setCurrentUser(_ user: UserProfile) {
        self.currentUser = user
        self.isLoggedIn = true
        UserDefaults.standard.set(true, forKey: loggedInKey)
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userDefaultsKey)
        }
    }
    
    private func getRegisteredUsers() -> [String: String] {
        return UserDefaults.standard.dictionary(forKey: usersDatabaseKey) as? [String: String] ?? [:]
    }
    
    private func saveRegisteredUsers(_ users: [String: String]) {
        UserDefaults.standard.set(users, forKey: usersDatabaseKey)
    }
    
    private func hashedPassword(_ password: String) -> String {
        let digest = SHA256.hash(data: Data(password.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    private func passwordsMatch(_ password: String, stored: String) -> Bool {
        stored == hashedPassword(password) || stored == password
    }
}

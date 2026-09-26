import Foundation
import SwiftUI
import Combine

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
    
    public init() {
        self.isLoggedIn = UserDefaults.standard.bool(forKey: loggedInKey)
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.currentUser = user
        }
    }
    
    // MARK: - Email & Password Validation
    
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
    
    // MARK: - Sign Up
    
    public func signUp(email: String, password: String, name: String) -> Bool {
        authErrorMessage = nil
        let cleanEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard isValidEmail(cleanEmail) else {
            authErrorMessage = "Please enter a valid email address (e.g., user@example.com)."
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
        
        // Save registered user
        registered[cleanEmail] = password
        saveRegisteredUsers(registered)
        
        let displayName = cleanName.isEmpty ? cleanEmail.components(separatedBy: "@").first?.capitalized ?? "Chef" : cleanName
        let user = UserProfile(email: cleanEmail, name: displayName)
        setCurrentUser(user)
        return true
    }
    
    // MARK: - Sign In
    
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
        if let storedPassword = registered[cleanEmail] {
            if storedPassword == password {
                let displayName = cleanEmail.components(separatedBy: "@").first?.capitalized ?? "Chef"
                let user = UserProfile(email: cleanEmail, name: displayName)
                setCurrentUser(user)
                return true
            } else {
                authErrorMessage = "Incorrect password. Please try again."
                return false
            }
        } else {
            // First time login with valid credentials creates the account seamlessly
            let displayName = cleanEmail.components(separatedBy: "@").first?.capitalized ?? "Chef"
            var updated = registered
            updated[cleanEmail] = password
            saveRegisteredUsers(updated)
            
            let user = UserProfile(email: cleanEmail, name: displayName)
            setCurrentUser(user)
            return true
        }
    }
    
    // MARK: - Sign Out
    
    public func signOut() {
        self.isLoggedIn = false
        self.currentUser = nil
        UserDefaults.standard.set(false, forKey: loggedInKey)
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    // MARK: - Persistence Helpers
    
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
}

import SwiftUI

public struct AuthOnboardingView: View {
    @ObservedObject var authService = AuthService.shared
    
    @State private var isSignUpMode: Bool = true
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var fullName: String = ""
    @State private var showPassword: Bool = false
    
    public init() {}
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header & Branding
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color.green.opacity(0.8), Color.accentColor],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 88, height: 88)
                            .shadow(color: Color.accentColor.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: "cabinet.fill")
                            .font(.system(size: 44))
                            .foregroundColor(.white)
                    }
                    .padding(.top, 24)
                    
                    Text("SmartPantry")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                    
                    Text("Intelligent receipt scanning, food expiration tracking, and zero-waste rewards.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                
                // Value Proposition Feature Pills
                HStack(spacing: 12) {
                    FeaturePill(icon: "doc.viewfinder.fill", text: "Receipt OCR")
                    FeaturePill(icon: "clock.badge.checkmark.fill", text: "FDA Expiry API")
                    FeaturePill(icon: "gift.fill", text: "Gift Cards")
                }
                .padding(.horizontal)
                
                // Sign In / Sign Up Card
                VStack(spacing: 20) {
                    Picker("Auth Mode", selection: $isSignUpMode) {
                        Text("Create Account").tag(true)
                        Text("Sign In").tag(false)
                    }
                    .pickerStyle(.segmented)
                    .padding(.bottom, 4)
                    
                    // Name Field (Sign Up Only)
                    if isSignUpMode {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Full Name")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.secondary)
                                TextField("Your Name", text: $fullName)
                                    .textContentType(.name)
                            }
                            .padding()
                            .background(Color(UIColor.tertiarySystemFill))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Email Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email Address")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.secondary)
                            TextField("name@example.com", text: $email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                                .textContentType(.emailAddress)
                        }
                        .padding()
                        .background(Color(UIColor.tertiarySystemFill))
                        .cornerRadius(12)
                    }
                    
                    // Password Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password (min 6 characters)")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.secondary)
                            
                            if showPassword {
                                TextField("Password", text: $password)
                                    .autocapitalization(.none)
                                    .disableAutocorrection(true)
                            } else {
                                SecureField("Password", text: $password)
                                    .textContentType(isSignUpMode ? .newPassword : .password)
                            }
                            
                            Button {
                                showPassword.toggle()
                            } label: {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(UIColor.tertiarySystemFill))
                        .cornerRadius(12)
                    }
                    
                    // Error Notice
                    if let error = authService.authErrorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                            Text(error)
                                .font(.caption.weight(.medium))
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                    
                    // Submit Action Button
                    Button {
                        handleAuthSubmit()
                    } label: {
                        HStack {
                            Image(systemName: isSignUpMode ? "person.crop.circle.badge.plus" : "arrow.right.circle.fill")
                            Text(isSignUpMode ? "Create Account & Continue" : "Sign In")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.accentColor)
                        .cornerRadius(14)
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                    .padding(.top, 4)
                    
                    // Quick Demo Fill for Testing
                    Button {
                        self.email = "alex@smartpantry.app"
                        self.password = "pantry123"
                        self.fullName = "Alex Hunter"
                        handleAuthSubmit()
                    } label: {
                        Text("Instant Demo Sign In")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.accentColor)
                    }
                    .padding(.top, 2)
                }
                .padding(20)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 4)
                .padding(.horizontal)
                
                Spacer(minLength: 24)
            }
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
    }
    
    private func handleAuthSubmit() {
        if isSignUpMode {
            _ = authService.signUp(email: email, password: password, name: fullName)
        } else {
            _ = authService.signIn(email: email, password: password)
        }
    }
}

struct FeaturePill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption2.weight(.bold))
                .foregroundColor(.accentColor)
            Text(text)
                .font(.caption.weight(.medium))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
}

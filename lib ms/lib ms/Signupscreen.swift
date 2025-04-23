import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignUpScreen: View {
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedRole = "Member" // Default role
    @State private var showLogin = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showConfirmation = false

    private let db = Firestore.firestore()
    private let accentColor = Color(red: 0.1, green: 0.3, blue: 0.7)
    private let buttonGradient = LinearGradient(gradient: Gradient(colors: [Color(red: 0.9, green: 0.4, blue: 0.2), Color(red: 1.0, green: 0.6, blue: 0.4)]), startPoint: .leading, endPoint: .trailing)
    private let unselectedGradient = LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.85)]), startPoint: .leading, endPoint: .trailing)

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.98, green: 0.95, blue: 0.9), Color(red: 0.95, green: 0.95, blue: 0.95)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                Image(systemName: "person.fill.badge.plus")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(accentColor)
                    .padding(.top, 40)
                
                Text("Create Account")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundColor(accentColor)
                
                // Role Selection
                HStack(spacing: 10) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedRole = "Member"
                        }
                    }) {
                        Text("Member")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(selectedRole == "Member" ? .white : accentColor)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                            .background(
                                selectedRole == "Member" ? buttonGradient : unselectedGradient
                            )
                            .clipShape(Capsule())
                            .shadow(radius: selectedRole == "Member" ? 5 : 0)
                            .scaleEffect(selectedRole == "Member" ? 1.1 : 1.0)
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedRole = "Librarian"
                        }
                    }) {
                        Text("Librarian")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(selectedRole == "Librarian" ? .white : accentColor)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity)
                            .background(
                                selectedRole == "Librarian" ? buttonGradient : unselectedGradient
                            )
                            .clipShape(Capsule())
                            .shadow(radius: selectedRole == "Librarian" ? 5 : 0)
                            .scaleEffect(selectedRole == "Librarian" ? 1.1 : 1.0)
                    }
                }
                .padding(.horizontal, 25)
                
                // Input Fields
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(accentColor.opacity(0.7))
                        TextField("Name", text: $name)
                            .font(.system(size: 16, design: .rounded))
                            .textInputAutocapitalization(.words)
                            .padding(.vertical, 12)
                    }
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(name.isEmpty ? Color.gray.opacity(0.3) : (name.count >= 3 ? Color.green : Color.red), lineWidth: 1.5)
                    )
                    
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(accentColor.opacity(0.7))
                        TextField("Email", text: $email)
                            .font(.system(size: 16, design: .rounded))
                            .textInputAutocapitalization(.none)
                            .padding(.vertical, 12)
                    }
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(email.isEmpty ? Color.gray.opacity(0.3) : (email.contains("@") && email.contains(".") ? Color.green : Color.red), lineWidth: 1.5)
                    )
                    
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(accentColor.opacity(0.7))
                        SecureField("Password", text: $password)
                            .font(.system(size: 16, design: .rounded))
                            .padding(.vertical, 12)
                    }
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(password.isEmpty ? Color.gray.opacity(0.3) : (password.count >= 6 ? Color.green : Color.red), lineWidth: 1.5)
                    )
                    
                    HStack {
                        Image(systemName: "lock.fill")
                            .foregroundColor(accentColor.opacity(0.7))
                        SecureField("Confirm Password", text: $confirmPassword)
                            .font(.system(size: 16, design: .rounded))
                            .padding(.vertical, 12)
                    }
                    .padding(.horizontal)
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(confirmPassword.isEmpty ? Color.gray.opacity(0.3) : (confirmPassword == password && !password.isEmpty ? Color.green : Color.red), lineWidth: 1.5)
                    )
                }
                .padding(.horizontal, 25)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.system(size: 14, design: .rounded))
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red.opacity(0.5), lineWidth: 1)
                        )
                        .shadow(radius: 3)
                        .padding(.horizontal, 25)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.3), value: errorMessage)
                }
                
                Button(action: {
                    if validateInputs() {
                        signUp()
                    }
                }) {
                    Text("Sign Up")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .frame(maxWidth: 220)
                        .background(buttonGradient)
                        .clipShape(Capsule())
                        .shadow(radius: 5)
                }
                .disabled(isLoading)
                
                Button(action: {
                    showLogin = true
                }) {
                    Text("Already have an account? Log in")
                        .font(.system(size: 15, design: .rounded))
                        .foregroundColor(accentColor)
                        .underline()
                }
                .fullScreenCover(isPresented: $showLogin) {
                    LoginScreen()
                }
                
                Spacer()
            }
            .padding(.vertical)
        }
        .overlay(
            isLoading ? ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5) : nil
        )
        .alert(isPresented: $showConfirmation) {
            Alert(
                title: Text("Verification Sent"),
                message: Text("Please check your email to verify your account."),
                dismissButton: .default(Text("OK")) {
                    showLogin = true
                }
            )
        }
    }
    
    private func validateInputs() -> Bool {
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "All fields are required."
            return false
        }
        guard name.count >= 3 else {
            errorMessage = "Name must be at least 3 characters long."
            return false
        }
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Please enter a valid email address."
            return false
        }
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long."
            return false
        }
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return false
        }
        errorMessage = ""
        return true
    }
    
    private func generateRandomUserId() async throws -> String {
        let randomId = String(format: "%06d", Int.random(in: 100000...999999))
        
        // Check if userId exists in Firestore
        let query = db.collection("users").whereField("userId", isEqualTo: randomId)
        let snapshot = try await query.getDocuments()
        
        if snapshot.isEmpty {
            return randomId
        } else {
            // Recursively try again if ID is taken (rare)
            return try await generateRandomUserId()
        }
    }
    
    private func signUp() {
        isLoading = true
        errorMessage = ""
        
        let lowercaseEmail = email.lowercased()
        
        Task {
            do {
                // Generate unique 6-digit userId
                let userId = try await generateRandomUserId()
                
                // Create user in Firebase Auth
                let authResult = try await Auth.auth().createUser(withEmail: lowercaseEmail, password: password)
                let user = authResult.user
                
                // Send email verification
                try await user.sendEmailVerification()
                
                // Save user data to Firestore
                let userData: [String: Any] = [
                    "name": name.trimmingCharacters(in: .whitespacesAndNewlines),
                    "email": lowercaseEmail,
                    "role": selectedRole,
                    "userId": userId,
                    "joinedDate": Timestamp(date: Date()),
                    "membershipPlan": "None",
                    "membershipExpiryDate": NSNull(),
                    "settings": [
                        "notifications": true,
                        "darkMode": false
                    ]
                ]
                
                try await db.collection("users").document(user.uid).setData(userData)
                
                print("User data saved successfully for UID: \(user.uid), role: \(selectedRole), userId: \(userId)")
                showConfirmation = true
            } catch {
                errorMessage = error.localizedDescription
                print("Sign-up error: \(errorMessage)")
            }
            isLoading = false
        }
    }
}

struct SignUpScreen_Previews: PreviewProvider {
    static var previews: some View {
        SignUpScreen()
    }
}

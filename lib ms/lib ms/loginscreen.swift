import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

struct LoginScreen: View {
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole = "Member"
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var navigateToAdmin = false
    @State private var navigateToLibrarian = false
    @State private var navigateToMember = false

    private let db = Firestore.firestore()
    private let accentColor = Color(red: 0.2, green: 0.4, blue: 0.6)
    private let buttonGradient = LinearGradient(gradient: Gradient(colors: [Color(red: 0.8, green: 0.4, blue: 0.2), Color(red: 0.9, green: 0.5, blue: 0.3)]), startPoint: .leading, endPoint: .trailing)
    private let adminEmails = ["admin1@library.com", "admin2@library.com", "admin@anybook.com"]

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.92, blue: 0.88), Color(red: 0.9, green: 0.87, blue: 0.83)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 25) {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(accentColor)
                        .padding(.top, 40)
                    
                    Text("Login")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(accentColor)
                    
                    VStack(spacing: 15) {
                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.none)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        
                        Picker("Role", selection: $selectedRole) {
                            Text("Member").tag("Member")
                            Text("Librarian").tag("Librarian")
                            Text("Admin").tag("Admin")
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: login) {
                        Text("Login")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 200)
                            .background(buttonGradient)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .disabled(isLoading)
                    
                    Button(action: { showSignUp = true }) {
                        Text("Sign Up")
                            .foregroundColor(accentColor)
                            .underline()
                    }
                    .fullScreenCover(isPresented: $showSignUp) {
                        SignUpScreen()
                    }
                    
                    Button(action: { showForgotPassword = true }) {
                        Text("Forgot Password?")
                            .foregroundColor(accentColor)
                            .underline()
                    }
                    .fullScreenCover(isPresented: $showForgotPassword) {
                        ForgotPasswordScreen()
                    }
                    
                    Spacer()
                }
                .padding()
                .fullScreenCover(isPresented: $navigateToAdmin) {
                    AdminHomePage()
                }
//                .fullScreenCover(isPresented: $navigateToLibrarian) {
//                    LibrarianHomePage()
//                }
                .fullScreenCover(isPresented: $navigateToMember) {
                    // Replace with MemberHomePage when implemented
                    HomePage(role: "Member")
                }
            }
            .overlay(
                isLoading ? ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5) : nil
            )
            .onAppear {
                createAdminAccounts()
            }
        }
    }
    
    private func login() {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter email and password."
            isLoading = false
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        print("Attempting login with email: \(email), selected role: \(selectedRole)")
        
        Auth.auth().signIn(withEmail: email.lowercased(), password: password) { result, error in
            isLoading = false
            if let error = error as NSError? {
                print("Login error: \(error.localizedDescription), code: \(error.code)")
                switch error.code {
                case AuthErrorCode.wrongPassword.rawValue:
                    errorMessage = "Incorrect password. Please try again or use 'Forgot Password'."
                case AuthErrorCode.userNotFound.rawValue, AuthErrorCode.invalidEmail.rawValue:
                    errorMessage = "No account found with this email. Please sign up or check admin account creation."
                case AuthErrorCode.weakPassword.rawValue:
                    errorMessage = "Password is too weak. Please use a stronger password."
                default:
                    errorMessage = "Login failed: \(error.localizedDescription)"
                }
                return
            }
            
            guard let user = result?.user else {
                errorMessage = "Unexpected error: No user found after login."
                print("Unexpected error: No user found")
                return
            }
            
            print("Login successful, user UID: \(user.uid)")
            
            // Check Firestore for user role
            db.collection("users").document(user.uid).getDocument { document, error in
                if let error = error {
                    errorMessage = "Failed to fetch user data: \(error.localizedDescription)"
                    print("Firestore error: \(errorMessage)")
                    return
                }
                
                guard let document = document, document.exists, let data = document.data(),
                      let role = data["role"] as? String else {
                    errorMessage = "User data or role not found. Ensure admin account is created."
                    print("Firestore error: User data not found for UID: \(user.uid)")
                    return
                }
                
                print("Firestore role: \(role), data: \(data)")
                
                // Validate role and email for Admin
                switch role {
                case "Admin":
                    print("Checking admin email: \(email.lowercased()) in \(adminEmails)")
                    if adminEmails.contains(email.lowercased()) {
                        navigateToAdmin = true
                    } else {
                        errorMessage = "Unauthorized: Only predefined admin accounts can select Admin role."
                    }
                case "Librarian":
                    if selectedRole == "Librarian" {
                        navigateToLibrarian = true
                    } else {
                        errorMessage = "Selected role does not match your account. Please select Librarian."
                    }
                case "Member":
                    if selectedRole == "Member" {
                        navigateToMember = true
                    } else {
                        errorMessage = "Selected role does not match your account. Please select Member."
                    }
                default:
                    errorMessage = "Invalid role: \(role)"
                }
            }
        }
    }
    
    private func createAdminAccounts() {
        let adminAccounts: [(email: String, password: String, name: String, userId: String, dateJoined: String?)] = [
            (email: "admin1@library.com", password: "Admin123!", name: "Admin One", userId: "100001", dateJoined: nil),
            (email: "admin2@library.com", password: "Admin456!", name: "Admin Two", userId: "100002", dateJoined: nil),
            (email: "admin@anybook.com", password: "Admin@2025!", name: "Admin User", userId: "adminCustomId", dateJoined: "2025-04-25")
        ]
        
        for admin in adminAccounts {
            print("Checking admin account: \(admin.email)")
            Auth.auth().fetchSignInMethods(forEmail: admin.email) { methods, error in
                if let error = error {
                    print("Error checking admin email: \(error.localizedDescription)")
                    return
                }
                
                if methods?.isEmpty ?? true {
                    // Admin account doesn't exist, create it
                    print("Creating admin account: \(admin.email)")
                    Auth.auth().createUser(withEmail: admin.email, password: admin.password) { result, error in
                        if let error = error as NSError? {
                            print("Error creating admin account: \(error.localizedDescription), code: \(error.code)")
                            if error.code == AuthErrorCode.emailAlreadyInUse.rawValue {
                                // Account exists, try signing in to update Firestore
                                Auth.auth().signIn(withEmail: admin.email, password: admin.password) { _, signInError in
                                    if let signInError = signInError {
                                        print("Failed to sign in existing admin: \(signInError.localizedDescription)")
                                    } else {
                                        saveAdminData(uid: Auth.auth().currentUser?.uid, admin: admin)
                                    }
                                }
                            }
                            return
                        }
                        
                        guard let user = result?.user else {
                            print("No user created for admin: \(admin.email)")
                            return
                        }
                        
                        saveAdminData(uid: user.uid, admin: admin)
                    }
                } else {
                    // Account exists, ensure Firestore data is correct
                    print("Admin account exists: \(admin.email), updating Firestore")
                    Auth.auth().signIn(withEmail: admin.email, password: admin.password) { _, error in
                        if let error = error {
                            print("Failed to sign in to update Firestore: \(error.localizedDescription)")
                            return
                        }
                        if let uid = Auth.auth().currentUser?.uid {
                            saveAdminData(uid: uid, admin: admin)
                        }
                    }
                }
            }
        }
    }
    
    private func saveAdminData(uid: String?, admin: (email: String, password: String, name: String, userId: String, dateJoined: String?)) {
        guard let uid = uid else {
            print("No UID for admin: \(admin.email)")
            return
        }
        
        var userData: [String: Any] = [
            "name": admin.name,
            "email": admin.email,
            "role": "Admin",
            "userId": admin.userId,
            "joinedDate": admin.dateJoined != nil ? Timestamp(date: dateFormatter.date(from: admin.dateJoined!) ?? Date()) : Timestamp(date: Date()),
            "membershipPlan": "None",
            "membershipExpiryDate": NSNull(),
            "settings": ["notifications": true, "darkMode": false]
        ]
        
        db.collection("users").document(uid).setData(userData) { error in
            if let error = error {
                print("Error saving admin data: \(error.localizedDescription)")
            } else {
                print("Admin account created/updated: \(admin.email), UID: \(uid)")
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}

struct ForgotPasswordScreen: View {
    @State private var email = ""
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showLogin = false

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.92, blue: 0.88), Color(red: 0.9, green: 0.87, blue: 0.83)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                Image(systemName: "lock.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                    .padding(.top, 40)
                
                Text("Forgot Password")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                
                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.none)
                        .padding()
                        .background(Color.white.opacity(0.9))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .padding(.horizontal, 20)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Button(action: resetPassword) {
                    Text("Reset Password")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.8, green: 0.4, blue: 0.2), Color(red: 0.9, green: 0.5, blue: 0.3)]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                .disabled(isLoading)
                
                Button(action: { showLogin = true }) {
                    Text("Back to Login")
                        .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                        .underline()
                }
                .fullScreenCover(isPresented: $showLogin) {
                    LoginScreen()
                }
                
                Spacer()
            }
            .padding()
            .overlay(
                isLoading ? ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5) : nil
            )
        }
    }
    
    private func resetPassword() {
        isLoading = true
        errorMessage = ""
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            isLoading = false
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                errorMessage = "Password reset email sent. Check your inbox."
                showLogin = true
            }
        }
    }
}

struct LoginScreen_Previews: PreviewProvider {
    static var previews: some View {
        LoginScreen()
    }
}

struct ForgotPasswordScreen_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordScreen()
    }
}

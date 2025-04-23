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
                    HomePage(role: "member")
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
                    errorMessage = "No account found with this email. Please sign up."
                default:
                    errorMessage = error.localizedDescription
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
                    errorMessage = "User data or role not found."
                    print("Firestore error: User data not found")
                    return
                }
                
                print("Firestore role: \(role)")
                
                // Navigate based on Firestore role, not selectedRole
                switch role {
                case "Admin":
                    navigateToAdmin = true
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
                    errorMessage = "Invalid role."
                }
            }
        }
    }
    
    private func createAdminAccounts() {
        let adminAccounts = [
            (email: "admin1@library.com", password: "Admin123!", name: "Admin One", userId: "100001"),
            (email: "admin2@library.com", password: "Admin456!", name: "Admin Two", userId: "100002")
        ]
        
        for admin in adminAccounts {
            Auth.auth().fetchSignInMethods(forEmail: admin.email) { methods, error in
                if let error = error {
                    print("Error checking admin email: \(error.localizedDescription)")
                    return
                }
                
                if methods?.isEmpty ?? true {
                    // Admin account doesn't exist, create it
                    Auth.auth().createUser(withEmail: admin.email, password: admin.password) { result, error in
                        if let error = error {
                            print("Error creating admin account: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let user = result?.user else { return }
                        
                        let userData: [String: Any] = [
                            "name": admin.name,
                            "email": admin.email,
                            "role": "Admin",
                            "userId": admin.userId,
                            "joinedDate": Timestamp(date: Date()),
                            "membershipPlan": "None",
                            "membershipExpiryDate": NSNull(),
                            "settings": ["notifications": true, "darkMode": false]
                        ]
                        
                        db.collection("users").document(user.uid).setData(userData) { error in
                            if let error = error {
                                print("Error saving admin data: \(error.localizedDescription)")
                            } else {
                                print("Admin account created: \(admin.email)")
                            }
                        }
                    }
                }
            }
        }
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

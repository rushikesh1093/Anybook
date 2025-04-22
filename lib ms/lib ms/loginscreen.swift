import SwiftUI
import FirebaseCore
import FirebaseAuth

struct LoginScreen: View {
    @State private var email = ""
    @State private var password = ""
    @State private var selectedRole = "Member"
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var isLoggedIn = false

    var body: some View {
        NavigationStack { // Replaced NavigationView with NavigationStack for modern SwiftUI
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.92, blue: 0.88), Color(red: 0.9, green: 0.87, blue: 0.83)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 25) {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                        .padding(.top, 40)
                    
                    Text("Login")
                        .font(.system(size: 32, weight: .bold))
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
                    
                    Button(action: {
                        login()
                    }) {
                        Text("Login")
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: 200)
                            .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.8, green: 0.4, blue: 0.2), Color(red: 0.9, green: 0.5, blue: 0.3)]), startPoint: .leading, endPoint: .trailing))
                            .cornerRadius(12)
                            .shadow(radius: 5)
                    }
                    .disabled(isLoading)
                    
                    Button(action: {
                        showSignUp = true
                    }) {
                        Text("Sign Up")
                            .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                            .underline()
                    }
                    .fullScreenCover(isPresented: $showSignUp) {
                        SignUpScreen()
                    }
                    
                    Button(action: {
                        showForgotPassword = true
                    }) {
                        Text("Forgot Password?")
                            .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                            .underline()
                    }
                    .fullScreenCover(isPresented: $showForgotPassword) {
                        ForgotPasswordScreen()
                    }
                    
                    Spacer()
                }
                .padding()
                .navigationDestination(isPresented: $isLoggedIn) {
                    HomePage(role: selectedRole)
                }
            }
            .overlay(
                isLoading ? ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5) : nil
            )
        }
    }
    
    private func login() {
        isLoading = true
        errorMessage = ""
        
        print("Attempting login with email: \(email), role: \(selectedRole)")
        
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
            } else if let user = Auth.auth().currentUser {
                print("Login successful, user UID: \(user.uid)")
                isLoggedIn = true
            } else {
                print("Unexpected error: No user found after login attempt")
                errorMessage = "Unexpected error: No user found after login."
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
                    .font(.system(size: 32, weight: .bold))
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
                
                Button(action: {
                    resetPassword()
                }) {
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
                
                Button(action: {
                    showLogin = true
                }) {
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
        }
        .overlay(
            isLoading ? ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5) : nil
        )
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

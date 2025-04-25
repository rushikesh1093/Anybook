//
//  AddLibrarianView.swift
//  lib ms
//
//  Created by admin12 on 25/04/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddLibrarianView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var personalEmail = ""
    @State private var govtDocNumber = ""
    @State private var errorMessage = ""
    @State private var isAdminSignedIn = false
    @State private var adminUid: String? // Store admin UID to restore after creating new user
    var onSave: ((id: String, name: String, role: String, email: String, personalEmail: String, govtDocNumber: String, dateJoined: String)) -> Void
    private let db = Firestore.firestore()

    // Regex pattern for Aadhaar (12 digits)
    private let aadhaarPattern = "^[0-9]{12}$"

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Add New Librarian")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)

                // Name Field
                VStack(alignment: .leading) {
                    Text("Name")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("Enter name", text: $name)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // Personal Email Field
                VStack(alignment: .leading) {
                    Text("Personal Email")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("Enter personal email", text: $personalEmail)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                .padding(.horizontal)

                // Government Document Number Field
                VStack(alignment: .leading) {
                    Text("Government Doc Number (Aadhaar Preferred)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    TextField("Enter document number", text: $govtDocNumber)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .keyboardType(.numberPad)
                }
                .padding(.horizontal)

                // Error Message
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.horizontal)
                }

                Spacer()

                // Save Button
                Button(action: {
                    saveLibrarian()
                }) {
                    Text("Save")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(red: 0.2, green: 0.4, blue: 0.6))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .disabled(!isAdminSignedIn) // Disable until admin is signed in
            }
            .background(Color.white)
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
            .onAppear {
                signInAdmin()
            }
        }
    }

    private func signInAdmin() {
        let adminEmail = "admin@anybook.com"
        let adminPassword = "Admin@2025!"

        Auth.auth().signIn(withEmail: adminEmail, password: adminPassword) { result, error in
            if let error = error {
                errorMessage = "Admin login failed: \(error.localizedDescription)"
                print("Admin sign-in error: \(error.localizedDescription)")
                isAdminSignedIn = false
                return
            }
            isAdminSignedIn = true
            adminUid = result?.user.uid
            print("Admin signed in successfully, UID: \(result?.user.uid ?? "unknown")")
        }
    }

    private func saveLibrarian() {
        guard !name.isEmpty, !personalEmail.isEmpty, !govtDocNumber.isEmpty else {
            errorMessage = "All fields are required."
            return
        }
        guard personalEmail.contains("@") && personalEmail.contains(".") else {
            errorMessage = "Please enter a valid email address."
            return
        }
        guard govtDocNumber.range(of: aadhaarPattern, options: .regularExpression) != nil else {
            errorMessage = "Please enter a valid 12-digit Aadhaar number."
            return
        }

        let generatedEmail = generateEmail(from: name)
        let generatedPassword = generateStrongPassword()
        print("Generated credentials: Email: \(generatedEmail), Password: \(generatedPassword)")

        generateUniqueSixDigitUserId { userId in
            guard let userId = userId else {
                errorMessage = "Failed to generate a unique ID. Please try again."
                return
            }

            Auth.auth().createUser(withEmail: generatedEmail, password: generatedPassword) { authResult, error in
                if let error = error {
                    errorMessage = "Failed to create user in Authentication: \(error.localizedDescription)"
                    print("Authentication error: \(error.localizedDescription)")
                    return
                }
                guard let newUserUid = authResult?.user.uid else {
                    errorMessage = "Failed to retrieve new user UID."
                    return
                }
                print("New user created with UID: \(newUserUid)")

                // Store the new user data
                let dateJoined = formattedDate()
                let newUser = (id: userId, name: name, role: "Librarian", email: generatedEmail, personalEmail: personalEmail, govtDocNumber: govtDocNumber, dateJoined: dateJoined)

                let userData: [String: Any] = [
                    "userId": userId,
                    "name": name,
                    "role": "Librarian",
                    "email": generatedEmail,
                    "authUid": newUserUid,
                    "personalEmail": personalEmail,
                    "govtDocNumber": govtDocNumber,
                    "dateJoined": dateJoined
                ]

                // Save to Firestore
                db.collection("users").document(userId).setData(userData) { error in
                    if let error = error {
                        errorMessage = "Failed to save librarian: \(error.localizedDescription)"
                        print("Firestore error: \(error.localizedDescription)")
                        return
                    }

                    // Log credentials for testing
                    print("Credentials for login: Email: \(generatedEmail), Password: \(generatedPassword)")

                    // Call onSave with the new user tuple
                    onSave(newUser)

                    // Attempt to sign in with the new credentials to verify
                    Auth.auth().signIn(withEmail: generatedEmail, password: generatedPassword) { signInResult, signInError in
                        if let signInError = signInError {
                            print("Verification login failed: \(signInError.localizedDescription)")
                            errorMessage = "Created user, but verification login failed: \(signInError.localizedDescription)"
                            return
                        }
                        print("Verification login successful for \(generatedEmail), UID: \(signInResult?.user.uid ?? "unknown")")

                        // Restore admin session
                        Auth.auth().signIn(withEmail: "admin@anybook.com", password: "Admin@2025!") { _, error in
                            if let error = error {
                                errorMessage = "Failed to restore admin session: \(error.localizedDescription)"
                                print("Failed to restore admin session: \(error.localizedDescription)")
                                return
                            }
                            print("Admin session restored.")
                            dismiss()
                        }
                    }
                }
            }
        }
    }

    private func generateUniqueSixDigitUserId(completion: @escaping (String?) -> Void) {
        var newId = String(format: "%06d", Int.random(in: 100000...999999))
        db.collection("users").whereField("userId", isEqualTo: newId).getDocuments { snapshot, error in
            if let error = error {
                print("Error checking userId: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let snapshot = snapshot, !snapshot.isEmpty {
                generateUniqueSixDigitUserId(completion: completion)
            } else {
                completion(newId)
            }
        }
    }

    private func generateEmail(from name: String) -> String {
        let cleanName = name.lowercased().replacingOccurrences(of: " ", with: "")
        return "\(cleanName)@anybook.com"
    }

    private func generateStrongPassword() -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let numbers = "0123456789"
        let special = "!@#$%^&*()_+-=[]{}|;:,.<>?"
        let allChars = letters + numbers + special

        var password = ""
        password += String((letters.randomElement() ?? "A").uppercased()) // At least one uppercase letter
        password += String(letters.randomElement() ?? "a") // At least one lowercase letter
        password += String(numbers.randomElement() ?? "0") // At least one number
        password += String(special.randomElement() ?? "!") // At least one special character

        for _ in 0..<8 {
            password += String(allChars.randomElement() ?? "x")
        }

        return String(password.shuffled())
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func sendCredentialsEmail(to email: String, generatedEmail: String, password: String) {
        print("Sending email to \(email) with credentials:")
        print("Email: \(generatedEmail)")
        print("Password: \(password)")
    }
}

struct AddLibrarianView_Previews: PreviewProvider {
    static var previews: some View {
        AddLibrarianView(onSave: { _ in })
    }
}

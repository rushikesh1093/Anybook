import SwiftUI
import FirebaseFirestore

struct AddLibrarianView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var personalEmail = ""
    @State private var govtDocNumber = ""
    @State private var errorMessage = ""
    var onSave: ((id: String, name: String, role: String, email: String, dateJoined: String)) -> Void
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
            }
            .background(Color.white)
            .navigationBarItems(leading: Button("Cancel") {
                dismiss()
            })
        }
    }

    private func saveLibrarian() {
        // Validate inputs
        guard !name.isEmpty, !personalEmail.isEmpty, !govtDocNumber.isEmpty else {
            errorMessage = "All fields are required."
            return
        }
        guard personalEmail.contains("@") && personalEmail.contains(".") else {
            errorMessage = "Please enter a valid email address."
            return
        }
        // Validate Aadhaar number (12 digits)
        guard govtDocNumber.range(of: aadhaarPattern, options: .regularExpression) != nil else {
            errorMessage = "Please enter a valid 12-digit Aadhaar number."
            return
        }

        // Generate email and password
        let generatedEmail = generateEmail(from: name)
        let generatedPassword = generateStrongPassword()

        // Prepare user data
        let userId = UUID().uuidString
        let dateJoined = formattedDate()
        let newUser = (id: userId, name: name, role: "Librarian", email: generatedEmail, dateJoined: dateJoined)

        // Save to Firestore
        let userData: [String: Any] = [
            "userId": userId,
            "name": name,
            "role": "Librarian",
            "email": generatedEmail,
            "password": generatedPassword,
            "personalEmail": personalEmail,
            "govtDocNumber": govtDocNumber,
            "dateJoined": dateJoined
        ]

        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                errorMessage = "Failed to save librarian: \(error.localizedDescription)"
                return
            }

            // Send email with credentials (simulated API call)
            sendCredentialsEmail(to: personalEmail, generatedEmail: generatedEmail, password: generatedPassword)

            // Update local users list and dismiss
            onSave(newUser)
            dismiss()
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
        password += String(letters.randomElement()!).uppercased() // At least one uppercase letter
        password += String(letters.randomElement()!) // At least one lowercase letter
        password += String(numbers.randomElement()!) // At least one number
        password += String(special.randomElement()!) // At least one special character

        // Fill the rest to make it 12 characters long
        for _ in 0..<8 {
            password += String(allChars.randomElement()!)
        }

        return String(password.shuffled())
    }

    private func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    private func sendCredentialsEmail(to email: String, generatedEmail: String, password: String) {
        // Simulated API call to send email
        print("Sending email to \(email) with credentials:")
        print("Email: \(generatedEmail)")
        print("Password: \(password)")

        // In a real app, you would call a backend API here to send the email.
        // Example using URLSession (requires a backend server):
        /*
        let url = URL(string: "https://your-backend-api/send-email")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "to": email,
            "subject": "Your Librarian Account Credentials",
            "body": "Your login credentials:\nEmail: \(generatedEmail)\nPassword: \(password)"
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Failed to send email: \(error.localizedDescription)")
            } else {
                print("Email sent successfully")
            }
        }.resume()
        */
    }
}

struct AddLibrarianView_Previews: PreviewProvider {
    static var previews: some View {
        AddLibrarianView(onSave: { _ in })
    }
}
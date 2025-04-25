import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AdminHomePage: View {
    @State private var name = "Loading..."
    @State private var userId = ""
    @State private var role = ""
    @State private var bookCount = 0
    @State private var userCount = 0
    @State private var librarianCount = 0
    @State private var totalFine = 0
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showLogin = false

    private let db = Firestore.firestore()
    private let backgroundColor = Color(red: 0.96, green: 0.90, blue: 0.81)
    private let accentColor = Color(red: 0.2, green: 0.4, blue: 0.6)

    var body: some View {
        ZStack {
            if showLogin {
                LoginScreen()
            } else {
                mainContentView
            }
        }
    }

    private var mainContentView: some View {
        ZStack {
            backgroundColor
                .edgesIgnoringSafeArea(.all)

            if role == "Admin" {
                NavigationView {
                    TabView {
                        ScrollView {
                            VStack(spacing: 20) {
                                headerView
                                statsGridView
                                if !errorMessage.isEmpty {
                                    errorMessageView
                                }
                                Spacer()
                            }
                            .padding(.vertical)
                        }
                        .tabItem {
                            Image(systemName: "house.fill")
                            Text("Home")
                        }

                        UserManagementView()
                            .tabItem {
                                Image(systemName: "person.2.fill")
                                Text("Users")
                            }

                        AdminBooksManagementView()
                            .tabItem {
                                Image(systemName: "book.fill")
                                Text("Catalog")
                            }
                    }
                    .accentColor(accentColor) // Color for selected tab icons and text
                    .background(backgroundColor) // Background color for the tab bar
                }
                .overlay(
                    isLoading ? ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5) : nil
                )
            } else {
                unauthorizedView
            }
        }
        .onAppear {
            fetchUserData()
            fetchLibraryStats()
        }
    }

    private var headerView: some View {
        HStack {
            Text("Good Morning")
                .font(.system(size: 24, weight: .bold, design: .default))
                .foregroundColor(.black)
            Spacer()
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }

    private var statsGridView: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            StatView(title: "TOTAL USERS", value: "\(userCount)", icon: "person.fill")
            StatView(title: "LIBRARIANS", value: "\(librarianCount)", icon: "calendar")
            StatView(title: "TOTAL BOOKS", value: "\(bookCount)", icon: "book.fill")
            StatView(title: "TOTAL FINE", value: "\(totalFine)", icon: "creditcard.fill")
        }
        .padding(.horizontal, 20)
    }

    private var errorMessageView: some View {
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
            .padding(.horizontal, 20)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeInOut(duration: 0.3), value: errorMessage)
    }

    private var unauthorizedView: some View {
        VStack {
            Text("Unauthorized Access")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundColor(.red)
            Text("You are not authorized to access the Admin dashboard.")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
            Button(action: logoutAction) {
                Text("Log Out")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: 220)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]), startPoint: .leading, endPoint: .trailing))
                    .clipShape(Capsule())
                    .shadow(radius: 5)
            }
        }
        .padding()
    }

    private func fetchUserData() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user logged in."
            role = ""
            return
        }

        isLoading = true
        db.collection("users").document(user.uid).getDocument { document, error in
            isLoading = false
            if let error = error {
                errorMessage = "Failed to fetch user data: \(error.localizedDescription)"
                print("Firestore error: \(errorMessage)")
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                errorMessage = "User data not found."
                print("Firestore error: User data not found")
                return
            }

            name = data["name"] as? String ?? "Unknown"
            userId = data["userId"] as? String ?? "N/A"
            role = data["role"] as? String ?? ""
        }
    }

    private func fetchLibraryStats() {
        isLoading = true

        db.collection("books").getDocuments { snapshot, error in
            if let error = error {
                errorMessage = "Failed to fetch books: \(error.localizedDescription)"
                print("Firestore error: \(errorMessage)")
                return
            }
            bookCount = snapshot?.documents.count ?? 0
        }

        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                errorMessage = "Failed to fetch users: \(error.localizedDescription)"
                print("Firestore error: \(errorMessage)")
                return
            }
            userCount = snapshot?.documents.count ?? 0

            let librarians = snapshot?.documents.filter { doc in
                let data = doc.data()
                return (data["role"] as? String) == "Librarian"
            }
            librarianCount = librarians?.count ?? 0
        }

        totalFine = 25
        isLoading = false
    }

    private func logoutAction() {
        do {
            try Auth.auth().signOut()
            showLogin = true
            print("Logged out successfully")
        } catch let signOutError as NSError {
            errorMessage = "Error signing out: \(signOutError.localizedDescription)"
            print("Logout error: \(errorMessage)")
        }
    }
}

struct StatView: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundColor(.gray)
            HStack {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .default))
                    .foregroundColor(.black)
                Spacer()
                Image(systemName: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundColor(icon == "creditcard.fill" ? .green : .orange)
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 3)
    }
}

struct AdminBooksManagementView: View {
    var body: some View {
        VStack {
            Text("Catalog Management")
                .font(.system(.title, design: .default, weight: .bold))
                .foregroundColor(.black)
            Text("Manage the library catalog, add/edit books, and monitor inventory.")
                .font(.system(size: 16, design: .default))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
        .padding()
    }
}

struct AdminHomePage_Previews: PreviewProvider {
    static var previews: some View {
        AdminHomePage()
    }
}

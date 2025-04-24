import SwiftUI
import FirebaseFirestore

struct UserManagementView: View {
    @State private var searchText = ""
    @State private var showLibrarians = true
    @State private var users: [(id: String, name: String, role: String)] = []
    @State private var errorMessage = ""
    @State private var isLoading = false

    private let db = Firestore.firestore()

    var filteredUsers: [(id: String, name: String, role: String)] {
        let roleFiltered = users.filter { user in
            showLibrarians ? user.role == "Librarian" : user.role != "Librarian"
        }
        if searchText.isEmpty {
            return roleFiltered
        } else {
            return roleFiltered.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        VStack {
            // Header
            HStack {
                Text("Users")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                Spacer()
                Button(action: {
                    // Placeholder for adding a new user
                    print("Add new user tapped")
                }) {
                    Image(systemName: "person.crop.circle.fill.badge.plus")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.orange)
                }
            }
            .padding(.horizontal)
            .padding(.top)

            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search employee", text: $searchText)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            .padding(.bottom, 8)

            // Toggle Buttons
            HStack {
                Button(action: {
                    showLibrarians = true
                }) {
                    Text("Librarian")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(showLibrarians ? Color.orange : Color.gray.opacity(0.3))
                        .cornerRadius(8)
                }
                Button(action: {
                    showLibrarians = false
                }) {
                    Text("Members")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(showLibrarians ? Color.gray.opacity(0.3) : Color.orange)
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding(.horizontal)

            // User List Header
            HStack {
                Text("ID")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .frame(width: 60, alignment: .leading)
                Text("Name")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            Divider()

            // User List
            if isLoading {
                ProgressView()
                    .padding()
            } else if !errorMessage.isEmpty {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else {
                List {
                    ForEach(filteredUsers, id: \.id) { user in
                        NavigationLink(destination: Text("User Detail: \(user.name)")) {
                            HStack {
                                Text(user.id)
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                    .frame(width: 60, alignment: .leading)
                                Text(user.name)
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.black)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }

            Spacer()
        }
        .background(Color.white)
        .onAppear {
            fetchUsers()
        }
    }

    private func fetchUsers() {
        isLoading = true
        db.collection("users").getDocuments { snapshot, error in
            isLoading = false
            if let error = error {
                errorMessage = "Failed to fetch users: \(error.localizedDescription)"
                print("Firestore error: \(errorMessage)")
                return
            }
            guard let documents = snapshot?.documents else {
                errorMessage = "No users found."
                return
            }

            users = documents.compactMap { doc in
                let data = doc.data()
                let userId = data["userId"] as? String ?? "N/A"
                let name = data["name"] as? String ?? "Unknown"
                let role = data["role"] as? String ?? "Member"
                return (id: userId, name: name, role: role)
            }
        }
    }
}

struct UserManagementView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserManagementView()
        }
    }
}
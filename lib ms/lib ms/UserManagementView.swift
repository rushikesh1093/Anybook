import SwiftUI
import FirebaseFirestore

struct UserManagementView: View {
    @State private var searchText = ""
    @State private var selectedRole = "Librarian"
    @State private var users: [(id: String, name: String, role: String, email: String, personalEmail: String, govtDocNumber: String, dateJoined: String)] = []
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showingAddLibrarianSheet = false

    private let db = Firestore.firestore()
    private let roleOptions = ["Librarian", "Members"]
    private let segmentControlColor = Color(red: 0.2, green: 0.4, blue: 0.6)
    private let addButtonColor = Color(red: 0.2, green: 0.4, blue: 0.6)

    var filteredUsers: [(id: String, name: String, role: String, email: String, personalEmail: String, govtDocNumber: String, dateJoined: String)] {
        let roleFiltered = users.filter { user in
            if selectedRole == "Librarian" {
                return user.role == "Librarian" && user.role != "Admin"
            } else {
                return user.role != "Librarian" && user.role != "Admin"
            }
        }
        if searchText.isEmpty {
            return roleFiltered
        } else {
            return roleFiltered.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }

    var body: some View {
        ZStack {
            VStack {
                // Header
                HStack {
                    Text("Users")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.black)
                    Spacer()
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

                // Segmented Control for Librarian/Members
                Picker("Role", selection: $selectedRole) {
                    ForEach(roleOptions, id: \.self) { role in
                        Text(role)
                            .font(.system(size: 18))
                            .foregroundColor(selectedRole == role ? .white : .black)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .tint(addButtonColor)
                .padding(.vertical, 10)
                .padding(.horizontal)
                .frame(height: 50)

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
                            NavigationLink(destination: UserDetailView(user: user)) {
                                HStack {
                                    Text(user.id)
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                        .frame(width: 60, alignment: .leading)
                                    Text(user.name)
                                        .font(.system(size: 16))
                                        .foregroundColor(.black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
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

            // Floating Action Button (Visible only when Librarian segment is selected)
            if selectedRole == "Librarian" {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingAddLibrarianSheet = true
                        }) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                                .padding()
                                .background(addButtonColor)
                                .clipShape(Circle())
                                .shadow(radius: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddLibrarianSheet) {
            AddLibrarianView(onSave: { newUser in
                // Convert the newUser tuple to match the updated structure
                let extendedUser = (id: newUser.id, name: newUser.name, role: newUser.role, email: newUser.email, personalEmail: "", govtDocNumber: "", dateJoined: newUser.dateJoined)
                users.append(extendedUser)
            })
        }
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
                var userId = data["userId"] as? String ?? "N/A"
                if userId != "N/A" {
                    userId = String(userId.prefix(6)).padding(toLength: 6, withPad: "0", startingAt: 0)
                }
                let name = data["name"] as? String ?? "Unknown"
                let role = data["role"] as? String ?? "Member"
                let email = data["email"] as? String ?? "N/A"
                let personalEmail = data["personalEmail"] as? String ?? "N/A"
                let govtDocNumber = data["govtDocNumber"] as? String ?? "N/A"
                let dateJoined = data["dateJoined"] as? String ?? "N/A"
                return (id: userId, name: name, role: role, email: email, personalEmail: personalEmail, govtDocNumber: govtDocNumber, dateJoined: dateJoined)
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

//
//  adminpage.swift
//  lib ms
//
//  Created by admin100 on 23/04/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct AdminHomePage: View {
    @State private var name = "Loading..."
    @State private var userId = ""
    @State private var role = ""
    @State private var bookCount = 0
    @State private var userCount = 0
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showLogin = false

    private let db = Firestore.firestore()
    private let accentColor = Color(red: 0.2, green: 0.4, blue: 0.6)
    private let buttonGradient = LinearGradient(gradient: Gradient(colors: [Color(red: 0.8, green: 0.4, blue: 0.2), Color(red: 0.9, green: 0.5, blue: 0.3)]), startPoint: .leading, endPoint: .trailing)

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
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.92, blue: 0.88), Color(red: 0.9, green: 0.87, blue: 0.83)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            if role == "Admin" {
                TabView {
                    // Home Tab
                    ScrollView {
                        VStack(spacing: 20) {
                            welcomeCard
                            statsCard
                            if !errorMessage.isEmpty {
                                errorMessageView
                            }
                            Spacer()
                        }
                        .padding(.vertical)
                    }
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                    
                    // Users Management Tab
                    AdminUsersManagementView()
                        .tabItem {
                            Label("Users", systemImage: "person.2.fill")
                        }
                    
                    // Books Tab
                    AdminBooksManagementView()
                        .tabItem {
                            Label("Books", systemImage: "book.fill")
                        }
                    
                    // Profile Tab
                    ProfileTabView(role: "Admin", logoutAction: logoutAction)
                        .tabItem {
                            ProfileIcon(name: name)
                        }
                }
                .accentColor(accentColor)
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
    
    // MARK: - Subviews
    
    private var welcomeCard: some View {
        VStack(spacing: 15) {
            Image(systemName: "house.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(accentColor)
            
            Text("Welcome, \(name)")
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundColor(accentColor)
            
            Text("Admin Dashboard")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(accentColor.opacity(0.8))
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 5)
        .padding(.horizontal, 20)
        .padding(.top, 20)
    }
    
    private var statsCard: some View {
        VStack(spacing: 15) {
            Text("Library Overview")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundColor(accentColor)
            
            HStack(spacing: 20) {
                StatView(title: "Total Books", value: "\(bookCount)", icon: "book.fill")
                StatView(title: "Active Users", value: "\(userCount)", icon: "person.2.fill")
            }
        }
        .padding()
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 5)
        .padding(.horizontal, 20)
        .transition(.move(edge: .bottom).combined(with: .opacity))
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
    
    // MARK: - Functions
    
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
        
        // Fetch book count
        db.collection("books").getDocuments { snapshot, error in
            if let error = error {
                errorMessage = "Failed to fetch books: \(error.localizedDescription)"
                print("Firestore error: \(errorMessage)")
                return
            }
            bookCount = snapshot?.documents.count ?? 0
        }
        
        // Fetch user count
        db.collection("users").getDocuments { snapshot, error in
            isLoading = false
            if let error = error {
                errorMessage = "Failed to fetch users: \(error.localizedDescription)"
                print("Firestore error: \(errorMessage)")
                return
            }
            userCount = snapshot?.documents.count ?? 0
        }
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

// MARK: - Supporting Views

struct StatView: View {
    let title: String
    let value: String
    let icon: String
    private let accentColor = Color(red: 0.2, green: 0.4, blue: 0.6)
    
    var body: some View {
        VStack {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(accentColor)
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundColor(accentColor)
            Text(title)
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(accentColor.opacity(0.8))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(radius: 3)
    }
}

struct ProfileIcon: View {
    let name: String
    private let accentColor = Color(red: 0.2, green: 0.4, blue: 0.6)
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.9))
                .frame(width: 30, height: 30)
                .overlay(
                    Circle()
                        .stroke(LinearGradient(gradient: Gradient(colors: [accentColor, accentColor.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 2)
                )
                .shadow(radius: 2)
            
            if let initials = nameInitials() {
                Text(initials)
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(accentColor)
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(accentColor)
            }
        }
    }
    
    private func nameInitials() -> String? {
        let components = name.trimmingCharacters(in: .whitespacesAndNewlines).split(separator: " ")
        guard !components.isEmpty else { return nil }
        let initials = components.prefix(2).map { $0.first?.uppercased() ?? "" }.joined()
        return initials.isEmpty ? nil : initials
    }
}

struct AdminUsersManagementView: View {
    var body: some View {
        VStack {
            Text("Users Management")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
            Text("Manage all user accounts, assign roles, and oversee membership requests.")
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
        .padding()
    }
}

struct AdminBooksManagementView: View {
    var body: some View {
        VStack {
            Text("Books Management")
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
            Text("Manage the library catalog, add/edit books, and monitor inventory.")
                .font(.system(size: 16, design: .rounded))
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

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct ProfileTabView: View {
    let role: String
    let logoutAction: () -> Void
    @State private var username = "Loading..."
    @State private var userId = ""
    @State private var joinedDate: Date? = nil
    @State private var membershipExpiryDate: Date? = nil
    @State private var membershipPlan = "None"
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    @State private var errorMessage = ""
    @State private var isLoading = false

    private let db = Firestore.firestore()
    private let accentColor = Color(red: 0.1, green: 0.3, blue: 0.7)
    private let buttonGradient = LinearGradient(gradient: Gradient(colors: [Color(red: 0.9, green: 0.4, blue: 0.2), Color(red: 1.0, green: 0.6, blue: 0.4)]), startPoint: .leading, endPoint: .trailing)
    private let unselectedGradient = LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.85)]), startPoint: .leading, endPoint: .trailing)

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.98, green: 0.95, blue: 0.9), Color(red: 0.95, green: 0.95, blue: 0.95)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Card
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(accentColor)
                        
                        Text(username)
                            .font(.system(.title2, design: .rounded, weight: .bold))
                            .foregroundColor(accentColor)
                        
                        Text("Role: \(role)")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(accentColor.opacity(0.8))
                        
                        VStack(spacing: 8) {
                            Text("ID: \(userId)")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.gray)
                            
                            Text("Joined: \(joinedDate?.formatted(date: .abbreviated, time: .omitted) ?? "N/A")")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.gray)
                            
                            Text("Membership Expires: \(membershipExpiryDate?.formatted(date: .abbreviated, time: .omitted) ?? "Not Set")")
                                .font(.system(size: 14, design: .rounded))
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 5)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    // Membership Selection Card
                    VStack(spacing: 15) {
                        Text("Membership Plan")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundColor(accentColor)
                        
                        Text("Current Plan: \(membershipPlan) Month\(membershipPlan == "1" ? "" : "s")")
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(accentColor.opacity(0.8))
                        
                        HStack(spacing: 10) {
                            ForEach(["1", "3", "6", "12"], id: \.self) { plan in
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        selectMembershipPlan(plan)
                                    }
                                }) {
                                    Text("\(plan) Mo")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .foregroundColor(membershipPlan == plan ? .white : accentColor)
                                        .padding(.vertical, 10)
                                        .padding(.horizontal, 15)
                                        .background(
                                            membershipPlan == plan ? buttonGradient : unselectedGradient
                                        )
                                        .clipShape(Capsule())
                                        .shadow(radius: membershipPlan == plan ? 3 : 0)
                                        .scaleEffect(membershipPlan == plan ? 1.1 : 1.0)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 5)
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.3), value: membershipPlan)
                    
                    // General Settings
                    VStack(spacing: 15) {
                        Text("General Settings")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .foregroundColor(accentColor)
                        
                        Toggle("Enable Notifications", isOn: $notificationsEnabled)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(accentColor)
                            .onChange(of: notificationsEnabled) { newValue in
                                updateSettings()
                            }
                        
                        Toggle("Dark Mode", isOn: $darkModeEnabled)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(accentColor)
                            .onChange(of: darkModeEnabled) { newValue in
                                updateSettings()
                            }
                    }
                    .padding()
                    .background(Color.white.opacity(0.95))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 5)
                    .padding(.horizontal, 20)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    // Error Message
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
                            .padding(.horizontal, 20)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .animation(.easeInOut(duration: 0.3), value: errorMessage)
                    }
                    
                    // Buttons
                    Button(action: {
                        print("Edit Profile tapped")
                    }) {
                        Text("Edit Profile")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .frame(maxWidth: 220)
                            .background(buttonGradient)
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                    }
                    .padding(.vertical, 5)
                    
                    Button(action: {
                        logoutAction()
                    }) {
                        Text("Logout")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.vertical, 12)
                            .frame(maxWidth: 220)
                            .background(LinearGradient(gradient: Gradient(colors: [Color.red, Color.red.opacity(0.8)]), startPoint: .leading, endPoint: .trailing))
                            .clipShape(Capsule())
                            .shadow(radius: 5)
                    }
                    .padding(.vertical, 5)
                    
                    Spacer()
                }
                .padding(.vertical)
            }
        }
        .overlay(
            isLoading ? ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5) : nil
        )
        .onAppear {
            fetchUserData()
        }
    }
    
    private func fetchUserData() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user logged in."
            return
        }
        
        isLoading = true
        userId = user.uid
        joinedDate = user.metadata.creationDate
        
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
            
            username = data["username"] as? String ?? "Unknown"
            membershipPlan = data["membershipPlan"] as? String ?? "None"
            if let expiryTimestamp = data["membershipExpiryDate"] as? Timestamp {
                membershipExpiryDate = expiryTimestamp.dateValue()
            }
            if let settings = data["settings"] as? [String: Bool] {
                notificationsEnabled = settings["notifications"] ?? true
                darkModeEnabled = settings["darkMode"] ?? false
            }
        }
    }
    
    private func selectMembershipPlan(_ plan: String) {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user logged in."
            return
        }
        
        isLoading = true
        let months = Int(plan) ?? 1
        let expiryDate = Calendar.current.date(byAdding: .month, value: months, to: Date()) ?? Date()
        
        let data: [String: Any] = [
            "membershipPlan": plan,
            "membershipExpiryDate": Timestamp(date: expiryDate)
        ]
        
        db.collection("users").document(user.uid).updateData(data) { error in
            isLoading = false
            if let error = error {
                errorMessage = "Failed to update membership: \(error.localizedDescription)"
                print("Firestore error: \(errorMessage)")
            } else {
                membershipPlan = plan
                membershipExpiryDate = expiryDate
                errorMessage = ""
                print("Membership updated to \(plan) months, expires \(expiryDate.formatted())")
            }
        }
    }
    
    private func updateSettings() {
        guard let user = Auth.auth().currentUser else {
            errorMessage = "No user logged in."
            return
        }
        
        let data: [String: Any] = [
            "settings": [
                "notifications": notificationsEnabled,
                "darkMode": darkModeEnabled
            ]
        ]
        
        db.collection("users").document(user.uid).updateData(data) { error in
            if let error = error {
                errorMessage = "Failed to update settings: \(error.localizedDescription)"
                print("Firestore error: \(errorMessage)")
            } else {
                errorMessage = ""
                print("Settings updated: notifications=\(notificationsEnabled), darkMode=\(darkModeEnabled)")
            }
        }
    }
}

struct ProfileTabView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileTabView(role: "Member", logoutAction: {
            print("Logout tapped")
        })
    }
}

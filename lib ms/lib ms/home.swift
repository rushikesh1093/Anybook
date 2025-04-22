import SwiftUI
import FirebaseAuth

struct HomePage: View {
    let role: String
    @State private var isLoading = false
    @State private var showLogin = false
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            TabView {
                HomeTabView(role: role)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                BookCatalogTabView()
                    .tabItem {
                        Label("Catalog", systemImage: "book.fill")
                    }
                
                ExploreTabView()
                    .tabItem {
                        Label("Explore", systemImage: "magnifyingglass")
                    }
                
                ProfileTabView(role: role, logoutAction: logout)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
            }
            .accentColor(Color(red: 0.2, green: 0.4, blue: 0.6))
            .overlay(
                isLoading ? ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5) : nil
            )
            .fullScreenCover(isPresented: $showLogin) {
                LoginScreen()
            }
        }
    }
    
    private func logout() {
        isLoading = true
        errorMessage = ""
        
        do {
            try Auth.auth().signOut()
            isLoading = false
            showLogin = true
        } catch let error {
            isLoading = false
            errorMessage = "Logout failed: \(error.localizedDescription)"
        }
    }
}

// Home Tab View
struct HomeTabView: View {
    let role: String
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.92, blue: 0.88), Color(red: 0.9, green: 0.87, blue: 0.83)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                Image(systemName: roleIcon())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                    .padding(.top, 40)
                
                Text("Welcome, \(role)!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                
                Text("Your library hub for all things books.")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding()
        }
    }
    
    private func roleIcon() -> String {
        switch role {
        case "Member":
            return "person.fill"
        case "Librarian":
            return "books.vertical.fill"
        case "Admin":
            return "gearshape.fill"
        default:
            return "person.fill"
        }
    }
}

// Book Catalog Tab View
struct BookCatalogTabView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.92, blue: 0.88), Color(red: 0.9, green: 0.87, blue: 0.83)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                Image(systemName: "book.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                    .padding(.top, 40)
                
                Text("Book Catalog")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                
                Text("Browse our collection of books.")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Button(action: {
                    print("Browse catalog tapped")
                }) {
                    Text("Browse Now")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.8, green: 0.4, blue: 0.2), Color(red: 0.9, green: 0.5, blue: 0.3)]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

// Explore Tab View
struct ExploreTabView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.92, blue: 0.88), Color(red: 0.9, green: 0.87, blue: 0.83)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                    .padding(.top, 40)
                
                Text("Explore")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                
                Text("Discover new books and recommendations.")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Button(action: {
                    print("Explore tapped")
                }) {
                    Text("Start Exploring")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.8, green: 0.4, blue: 0.2), Color(red: 0.9, green: 0.5, blue: 0.3)]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

// Profile Tab View
struct HomePage_Previews: PreviewProvider {
    static var previews: some View {
        HomePage(role: "Member")
    }
}

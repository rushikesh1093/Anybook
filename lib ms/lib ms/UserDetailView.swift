import SwiftUI

struct UserDetailView: View {
    let user: (id: String, name: String, role: String, email: String, dateJoined: String)

    var body: some View {
        VStack(spacing: 20) {
            // Profile Photo (Placeholder)
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundColor(.gray)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                )
                .padding(.top, 20)

            // Name
            Text(user.name)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)

            // Email
            VStack(alignment: .leading, spacing: 5) {
                Text("Email")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                Text(user.email)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
            .padding(.horizontal)

            // Date Joined
            VStack(alignment: .leading, spacing: 5) {
                Text("Date Joined")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
                Text(user.dateJoined)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
            .padding(.horizontal)

            Spacer()
        }
        .background(Color.white)
        .navigationTitle("User Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserDetailView(user: ("001", "John Doe", "Librarian", "john@example.com", "2023-01-15"))
        }
    }
}
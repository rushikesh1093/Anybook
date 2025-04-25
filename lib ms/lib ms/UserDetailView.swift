//
//  UserDetailView.swift
//  lib ms
//
//  Created by [Your Name] on [Date]
//

import SwiftUI

struct UserDetailView: View {
    let user: (id: String, name: String, role: String, email: String, personalEmail: String, govtDocNumber: String, dateJoined: String)

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

            // Conditional Fields for Librarian
            if user.role == "Librarian" {
                // Personal Email
                VStack(alignment: .leading, spacing: 5) {
                    Text("Personal Email")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                    Text(user.personalEmail)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                // Government ID
                VStack(alignment: .leading, spacing: 5) {
                    Text("Government ID")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                    Text(user.govtDocNumber)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                // Official Email
                VStack(alignment: .leading, spacing: 5) {
                    Text("Official Email")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                    Text(user.email)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            } else {
                // Email for non-Librarian roles
                VStack(alignment: .leading, spacing: 5) {
                    Text("Email")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                    Text(user.email)
                        .font(.system(size: 18))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }

            // Date Joined
            VStack(alignment: .leading, spacing: 5) {
                Text("Date Joined")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.gray)
                Text(user.dateJoined)
                    .font(.system(size: 18))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
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
            UserDetailView(user: ("001", "John Doe", "Librarian", "johndoe@anybook.com", "john@example.com", "123456789012", "2023-01-15"))
        }
    }
}

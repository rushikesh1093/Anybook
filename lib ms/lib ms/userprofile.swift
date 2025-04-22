//
//  userprofile.swift
//  lib ms
//
//  Created by admin100 on 22/04/25.
//

import SwiftUI

struct ProfileTabView: View {
    let role: String
    let logoutAction: () -> Void
    @State private var errorMessage = ""

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(red: 0.95, green: 0.92, blue: 0.88), Color(red: 0.9, green: 0.87, blue: 0.83)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 25) {
                Image(systemName: "person.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                    .padding(.top, 40)
                
                Text("User Profile")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                
                Text("Role: \(role)")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                    .padding(.horizontal, 20)
                
                Text("Manage your account settings and view your activity.")
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }
                
                Button(action: {
                    print("Edit Profile tapped")
                }) {
                    Text("Edit Profile")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.8, green: 0.4, blue: 0.2), Color(red: 0.9, green: 0.5, blue: 0.3)]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                
                Button(action: {
                    logoutAction()
                }) {
                    Text("Logout")
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color.red)
                        .cornerRadius(12)
                        .shadow(radius: 5)
                }
                
                Spacer()
            }
            .padding()
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

//
//  LoginView.swift
//  prokiii
//
//  Created by Eddie XU on 2024-07-15.
//

import SwiftUI
import MongoKitten
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    @State private var email: String = "" // State variable for email input
    @State private var password: String = "" // State variable for password input
    @Binding var isLoginViewActive: Bool // Binding to manage the visibility of the login view
    @Binding var isLoggedIn: Bool // Binding to manage login status
    @EnvironmentObject var userInfo: UserInfo // Environment object to store user info

    @State private var showAlert: Bool = false // State variable to manage alert visibility
    @State private var alertMessage: String = "" // State variable to store alert message
    
    @ObservedObject private var googleSignInManager = GoogleSignInManager.shared // Observed object for Google Sign-In

    var body: some View {
        VStack {
            Spacer()
            Text("Login to Your Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 10)

            Text("Step into the World of Opportunities and Master Your Craft!")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)

            VStack(spacing: 16) {
                // Email text field
                TextField("Enter Your Email", text: $email)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 15)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .loginPlaceholder(when: email.isEmpty) {
                        Text("Enter Your Email")
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 15)
                    }

                // Password text field
                SecureField("Enter Your Password", text: $password)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 15)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .foregroundColor(.white)
                    .loginPlaceholder(when: password.isEmpty) {
                        Text("Enter Your Password")
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.horizontal, 15)
                    }

                // Login button
                Button(action: {
                    Task {
                        await handleLogin()
                    }
                }) {
                    HStack {
                        Text("Login to Your Account")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(LinearGradient(gradient: Gradient(colors: [Color.green, Color.yellow]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(10)
                    .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 20)

            Text("/")
                .foregroundColor(.white)
                .padding(.bottom, 20)

            VStack(spacing: 16) {
                // Google Sign-In button
                Button(action: {
                    if let presentingVC = UIApplication.shared.connectedScenes
                        .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
                       let rootVC = presentingVC.windows.first?.rootViewController {
                        googleSignInManager.signIn(presentingViewController: rootVC)
                    }
                }) {
                    HStack {
                        Image("google-favicon")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Sign in with Google")
                            .fontWeight(.semibold)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 1)
                    )
                    .foregroundColor(.white)
                }

                // Divider line
                Divider()
                    .frame(height: 2)
                    .background(Color.gray.opacity(0.5))
                    .padding(.vertical, 20)

                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    // Sign-up button
                    Button(action: {
                        isLoginViewActive = false
                    }) {
                        Text("Sign up here")
                            .foregroundColor(.blue)
                    }
                }
            }
            .padding(.horizontal, 40)

            Spacer()

            // Forgot password button (Imcomplete)
            Button(action: {
            }) {
                Text("Forgot Password?")
                    .foregroundColor(.gray)
                    .underline()
            }
            .padding(.bottom, 20)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Login Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onChange(of: googleSignInManager.isLoggedIn) { _, newValue in
            if newValue {
                isLoggedIn = true
            }
        }
    }

    // Function to handle login process
    func handleLogin() async {
        do {
            guard let collection = MongoDBManager.shared.getCollection(collectionName: "users") else {
                showAlert(with: "Failed to access the users collection.")
                return
            }

            let query: Document = [
                "email": email,
                "password": password
            ]

            if let user = try await collection.findOne(query) {
                print("Login successful for user: \(user)")
                userInfo.prokiiiID = user["prokiiiID"] as? String ?? ""
                userInfo.email = user["email"] as? String ?? ""
                isLoggedIn = true
            } else {
                showAlert(with: "Invalid email or password.")
            }
        } catch {
            showAlert(with: "Failed to login: \(error.localizedDescription)")
        }
    }

    // Function to display an alert
    func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
}

extension View {
    func loginPlaceholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}

class UserInfo: ObservableObject {
    @Published var prokiiiID: String = "" // Published variable to store prokiiiID
    @Published var email: String = "" // Published variable to store email
}

//
//  SignupView.swift
//  prokiii
//
//  Created by Eddie XU on 2024-07-15.
//

import SwiftUI
import MongoKitten

struct SignupView: View {
    @State private var email: String = "" // State variable for email input
    @State private var prokiiiID: String = "" // State variable for prokiiiID input
    @State private var password: String = "" // State variable for password input
    @Binding var isLoginViewActive: Bool // Binding to manage the visibility of the login view

    @State private var emailIsValid: Bool? = nil // State variable to validate email
    @State private var prokiiiIDIsValid: Bool? = nil // State variable to validate prokiiiID
    @State private var passwordIsValid: Bool? = nil // State variable to validate password

    @State private var showAlert: Bool = false // State variable to manage alert visibility
    @State private var alertMessage: String = "" // State variable to store alert message

    var body: some View {
        VStack {
            Spacer()
            Text("Create Your Account")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.bottom, 10)

            Text("You PRO from PROKI!!! Cheers ヽ(≧▽≦)ノ♡")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)

            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Email")
                        .foregroundColor(.gray)
                    TextField("Enter Your Email", text: $email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 15)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(emailIsValid == nil ? Color.clear : (emailIsValid! ? Color.green : Color.red), lineWidth: 2)
                        )
                        .signupPlaceholder(when: email.isEmpty) {
                            Text("Enter Your Email")
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 15)
                        }
                        .onChange(of: email) { _, newValue in
                            emailIsValid = isValidEmail(newValue)
                        }
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Prokiii ID")
                        .foregroundColor(.gray)
                    TextField("Enter Your Prokiii ID", text: $prokiiiID)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 15)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(prokiiiIDIsValid == nil ? Color.clear : (prokiiiIDIsValid! ? Color.green : Color.red), lineWidth: 2)
                        )
                        .signupPlaceholder(when: prokiiiID.isEmpty) {
                            Text("Enter Your Prokiii ID")
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 15)
                        }
                        .onChange(of: prokiiiID) { _, newValue in
                            prokiiiIDIsValid = isValidProkiiiID(newValue)
                        }
                    Text("Your Prokiii ID must be unique and contain 6-12 alphanumeric characters.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("Password")
                        .foregroundColor(.gray)
                    SecureField("Enter Your Password", text: $password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding(.horizontal, 15)
                        .padding(.vertical, 15)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(passwordIsValid == nil ? Color.clear : (passwordIsValid! ? Color.green : Color.red), lineWidth: 2)
                        )
                        .signupPlaceholder(when: password.isEmpty) {
                            Text("Enter Your Password")
                                .foregroundColor(.white.opacity(0.6))
                                .padding(.horizontal, 15)
                        }
                        .onChange(of: password) { _, newValue in
                            passwordIsValid = isValidPassword(newValue)
                        }
                    Text("Password must be at least 8 characters, including 1 uppercase letter, 1 lowercase letter, and 1 number.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .fixedSize(horizontal: false, vertical: true)
                }

                // Signup button
                Button(action: {
                    Task {
                        await handleSignup()
                    }
                }) {
                    HStack {
                        Text("Create Your Account")
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

            // Divider line
            Divider()
                .frame(height: 2)
                .background(Color.gray.opacity(0.5))
                .padding(.vertical, 20)

            HStack {
                Text("Already have an account?")
                    .foregroundColor(.gray)
                // Sign-in button
                Button(action: {
                    isLoginViewActive = true
                }) {
                    Text("Sign in here")
                        .foregroundColor(.blue)
                }
            }
            .padding(.bottom, 20)

            Spacer()
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Signup Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    // Function to validate email using regex
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Z0-9a-z.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }

    // Function to validate Prokiii ID using regex
    func isValidProkiiiID(_ id: String) -> Bool {
        let idRegex = "^[A-Za-z0-9]{6,12}$"
        return NSPredicate(format: "SELF MATCHES %@", idRegex).evaluate(with: id)
    }

    // Function to validate password using regex
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)[A-Za-z\\d@$!%*?&]{8,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }

    // Function to handle signup process
    func handleSignup() async {
        guard emailIsValid == true, prokiiiIDIsValid == true, passwordIsValid == true else {
            showAlert(with: "Please ensure all fields are filled correctly.")
            return
        }

        do {
            guard let collection = MongoDBManager.shared.getCollection(collectionName: "users") else {
                showAlert(with: "Failed to access the users collection.")
                return
            }

            let userDocument: Document = [
                "email": email,
                "prokiiiID": prokiiiID,
                "password": password,
            ]

            try await collection.insert(userDocument)

            isLoginViewActive = true // Switch to login view after successful signup
        } catch {
            showAlert(with: "Failed to sign up: \(error.localizedDescription)")
        }
    }

    // Function to display an alert
    func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
}

extension View {
    func signupPlaceholder<Content: View>(
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

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView(isLoginViewActive: .constant(false))
    }
}

//
//  ChangeProkiiiIDView.swift
//  prokiii
//
//  Created by Eddie XU on 2024-07-28.
//

import SwiftUI
import MongoKitten

// A view that allows users to change their Prokiii ID
struct ChangeProkiiiIDView: View {
    @Binding var isPresented: Bool
    @EnvironmentObject var userInfo: UserInfo
    @State private var newProkiiiID: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @ObservedObject private var googleSignInManager = GoogleSignInManager.shared

    var body: some View {
        VStack {
            Text("Change Your Prokiii ID")
                .font(.largeTitle)
                .padding(.top, 220)
            
            Text("Please enter a new Prokiii ID to update your profile.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)

            TextField("Enter new Prokiii ID", text: $newProkiiiID)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding(.horizontal, 15)
                .padding(.vertical, 15)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)

            Button(action: {
                Task {
                    await handleChangeProkiiiID()
                }
            }) {
                Text("Submit")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Change Prokiii ID"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    // Handles the change of the Prokiii ID
    func handleChangeProkiiiID() async {
        do {
            guard !newProkiiiID.isEmpty else {
                showAlert(with: "Prokiii ID cannot be empty.")
                return
            }

            let isGoogleUser = googleSignInManager.user != nil
            let userId = isGoogleUser ? googleSignInManager.user?.userID ?? "" : userInfo.prokiiiID
            
            try await MongoDBManager.shared.updateProkiiiID(for: userId, newProkiiiID: newProkiiiID, isGoogleUser: isGoogleUser)

            userInfo.prokiiiID = newProkiiiID
            alertMessage = "Prokiii ID successfully changed!"
            showAlert = true
            isPresented = false
        } catch {
            showAlert(with: "Failed to change Prokiii ID: \(error.localizedDescription)")
        }
    }

    // Displays an alert with a specified message
    func showAlert(with message: String) {
        alertMessage = message
        showAlert = true
    }
}

struct ChangeProkiiiIDView_Previews: PreviewProvider {
    static var previews: some View {
        ChangeProkiiiIDView(isPresented: .constant(true))
            .environmentObject(UserInfo())
    }
}

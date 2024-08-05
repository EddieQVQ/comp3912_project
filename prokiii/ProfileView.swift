//
//  ProfileView.swift
//  prokiii
//
//  Created by Eddie XU on 2024-07-16.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject private var googleSignInManager = GoogleSignInManager.shared // Manages Google Sign-In
    @Binding var isLoggedIn: Bool // Binding to track login status
    @EnvironmentObject var userInfo: UserInfo // Environment object to store user info

    @State private var showImagePicker: Bool = false // State variable to manage image picker visibility
    @State private var showChangeProkiiiIDView: Bool = false // State variable to manage Prokiii ID change view visibility
    @State private var profileImage: UIImage? = UIImage(named: "defaultProfileImage") // State variable to store profile image

    var body: some View {
        VStack {
            VStack {
                // Profile Image
                Image(uiImage: profileImage ?? UIImage(named: "defaultProfileImage")!)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .padding()

                // Display Prokiii ID and Email
                Text("Prokiii ID: \(userInfo.prokiiiID)")
                    .font(.headline)
                    .padding(.top, 10)

                Text("Email: \(userInfo.email)")
                    .font(.headline)
                    .padding(.top, 10)
            }
            .onAppear {
                fetchProfileImage() // Fetch profile image on view appear
                fetchUserInfo() // Fetch user info on view appear
            }
            .onChange(of: googleSignInManager.user) { oldValue, newValue in
                fetchProfileImage() // Fetch profile image on user change
                fetchUserInfo() // Fetch user info on user change
            }

            // Button to upload profile image
            Button(action: {
                showImagePicker = true
            }) {
                Text("Upload Profile Image")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 40)
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $profileImage, onImagePicked: uploadProfileImage)
            }

            // Button to change Prokiii ID
            Button(action: {
                showChangeProkiiiIDView = true
            }) {
                Text("Change Prokiii ID")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 40)
            .sheet(isPresented: $showChangeProkiiiIDView) {
                ChangeProkiiiIDView(isPresented: $showChangeProkiiiIDView)
                    .environmentObject(userInfo)
            }

            // Button to logout
            Button(action: {
                logout()
            }) {
                Text("Logout")
                    .fontWeight(.semibold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(10)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }

    // Function to handle user logout
    func logout() {
        googleSignInManager.signOut()
        handleProkiiiLogout()
        isLoggedIn = false
    }

    // Placeholder function for Prokiii-specific logout actions
    func handleProkiiiLogout() {
        print("Prokiii user logged out")
    }

    // Function to upload profile image
    func uploadProfileImage(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        let userId = googleSignInManager.user?.userID ?? userInfo.prokiiiID
        
        Task {
            do {
                try await MongoDBManager.shared.uploadProfileImage(for: userId, imageData: imageData, isGoogleUser: googleSignInManager.user != nil)
                fetchProfileImage() // Refresh profile image after upload
            } catch {
                print("Failed to upload profile image: \(error)")
            }
        }
    }

    // Function to fetch profile image
    func fetchProfileImage() {
        let userId = googleSignInManager.user?.userID ?? userInfo.prokiiiID
        
        Task {
            do {
                if let imageData = try await MongoDBManager.shared.fetchProfileImage(for: userId, isGoogleUser: googleSignInManager.user != nil) {
                    if let image = UIImage(data: imageData) {
                        DispatchQueue.main.async {
                            self.profileImage = image
                        }
                    }
                } else {
                    print("Failed to fetch profile image data from MongoDB")
                }
            } catch {
                print("Failed to fetch profile image: \(error)")
            }
        }
    }

    // Function to fetch user info
    func fetchUserInfo() {
        let userId = googleSignInManager.user?.userID ?? userInfo.prokiiiID
        
        Task {
            do {
                if let userDocument = try await MongoDBManager.shared.fetchUserDocument(for: userId, isGoogleUser: googleSignInManager.user != nil) {
                    userInfo.prokiiiID = userDocument["prokiiiID"] as? String ?? ""
                    userInfo.email = userDocument["email"] as? String ?? ""
                } else {
                    print("User document not found.")
                }
            } catch {
                print("Failed to fetch user info: \(error)")
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(isLoggedIn: .constant(true))
            .environmentObject(UserInfo())
    }
}

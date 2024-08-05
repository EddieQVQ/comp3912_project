//
//  GoogleSignInManager.swift
//  prokiii
//
//  Created by Eddie XU on 2024-07-16.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import MongoKitten

// Manages Google Sign-In and user information storage in MongoDB
class GoogleSignInManager: ObservableObject {
    static let shared = GoogleSignInManager()
    
    @Published var user: GIDGoogleUser?
    @Published var isLoggedIn: Bool = false
    
    init() {
        configureSignIn()
    }
    
    // Configures Google Sign-In with the client ID from the GoogleService-Info.plist file
    private func configureSignIn() {
        guard let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientID = plist["CLIENT_ID"] as? String else {
            print("Google Sign-In client ID not found.")
            return
        }
        
        let signInConfig = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = signInConfig
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            if let error = error {
                print("Failed to restore previous sign-in: \(error.localizedDescription)")
                return
            }
            self?.user = user
            self?.isLoggedIn = user != nil
            if let user = user {
                self?.storeUserToDatabase(user: user)
            }
        }
    }
    
    /// Initiates the Google Sign-In process
    /// - Parameter presentingViewController: The view controller that presents the sign-in screen
    func signIn(presentingViewController: UIViewController) {
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController) { [weak self] result, error in
            if let error = error {
                print("Google Sign-In failed: \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else { return }
            
            self?.user = user
            self?.isLoggedIn = result?.user != nil
            self?.storeUserToDatabase(user: user)
        }
    }
    
    /// Signs the user out of Google
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        user = nil
        isLoggedIn = false
    }
    
    /// Stores or updates the signed-in user's information in MongoDB
    /// - Parameter user: The signed-in Google user
    private func storeUserToDatabase(user: GIDGoogleUser) {
        Task {
            do {
                let userId = user.userID ?? ""
                let email = user.profile?.email ?? ""
                let profileImageUrl = user.profile?.imageURL(withDimension: 200)?.absoluteString ?? ""
                
                // Check if user exists
                guard let collection = MongoDBManager.shared.getCollection(collectionName: "users") else {
                    print("Failed to access the users collection.")
                    return
                }
                
                if try await collection.findOne("_id" == userId) != nil {
                    // Update existing user
                    try await collection.updateOne(where: "_id" == userId, to: ["$set": ["email": email, "profileImage": profileImageUrl]])
                } else {
                    // Assign a new Prokiii ID
                    let prokiiiID = "prokiii_" + String(Int.random(in: 10000...99999))
                    
                    let userDocument: Document = [
                        "_id": userId,
                        "email": email,
                        "profileImage": profileImageUrl,
                        "prokiiiID": prokiiiID
                    ]
                    
                    // Insert new user
                    try await collection.insert(userDocument)
                }
                
                print("User information stored/updated in MongoDB.")
            } catch {
                print("Failed to store user information: \(error.localizedDescription)")
            }
        }
    }
}

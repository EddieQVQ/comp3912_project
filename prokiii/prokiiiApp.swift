//
//  prokiiiApp.swift
//  prokiii
//
//  Created by Eddie XU on 2024-07-15.
//

import SwiftUI
import GoogleSignIn

@main
struct prokiiiiApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var userInfo = UserInfo()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(userInfo) // Inject userInfo as an environment object to be accessible across views
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    // Called when the application has finished launching. Sets up Google Sign-In.
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Restore any previous Google Sign-In sessions
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                print("Failed to restore previous sign-in: \(error.localizedDescription)")
            }
        }
        return true
    }

    // Handle URL schemes for Google Sign-In
    func application(_ app: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url) // Delegate URL handling to Google Sign-In instance
    }
}

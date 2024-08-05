//
//  ContentView.swift
//  prokiii
//
//  Created by Eddie XU on 2024-07-15.
//

import SwiftUI

struct ContentView: View {
    @State private var isLoginViewActive: Bool = true // State variable to manage login/signup view toggle
    @State private var isLoggedIn: Bool = false // State variable to manage login status

    var body: some View {
        VStack {
            if isLoggedIn {
                // Show HomeView if the user is logged in
                HomeView(isLoggedIn: $isLoggedIn)
            } else {
                // Toggle between LoginView and SignupView based on isLoginViewActive
                if isLoginViewActive {
                    LoginView(isLoginViewActive: $isLoginViewActive, isLoggedIn: $isLoggedIn)
                } else {
                    SignupView(isLoginViewActive: $isLoginViewActive)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView() 
    }
}


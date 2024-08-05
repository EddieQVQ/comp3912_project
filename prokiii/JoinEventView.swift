//
//  JoinEventView.swift
//  prokiii
//
//  Created by Eddie XU on 2024-07-29.
//

import SwiftUI
import MongoKitten

// A view for joining an event
struct JoinEventView: View {
    let event: Document // The event document to join
    @State private var teamName: String = "" // State property for the team name
    @State private var showAlert: Bool = false // State property to control alert presentation
    @State private var alertMessage: String = "" // State property for alert message
    @EnvironmentObject var userInfo: UserInfo // EnvironmentObject to access user information
    @Environment(\.presentationMode) var presentationMode // Environment property to control the presentation mode

    var body: some View {
        VStack {
            Text("Enter Team Name")
                .font(.headline)
                .padding()

            TextField("Team Name", text: $teamName)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

            Button(action: {
                joinEvent() // Call the joinEvent method
            }) {
                Text("Join Event")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()

            Spacer()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Join Event"), message: Text(alertMessage), dismissButton: .default(Text("OK")) {
                if alertMessage == "Successfully joined the event!" {
                    presentationMode.wrappedValue.dismiss() // Dismiss the view on successful join
                }
            })
        }
    }

    // Method to join the event
    private func joinEvent() {
        // Validate the team name input
        guard !teamName.isEmpty else {
            alertMessage = "Team Name cannot be empty."
            showAlert = true
            return
        }

        Task {
            do {
                // Create a query document for the participant
                let participantQuery: Document = ["eventID": event["_id"]!, "teamName": teamName]
                // Attempt to find the participant document in the collection
                var participant = try await MongoDBManager.shared.getCollection(collectionName: "participants")?.findOne(participantQuery)
                
                // If participant document doesn't exist, create a new one
                if participant == nil {
                    participant = ["eventID": event["_id"]!, "teamName": teamName, "members": [userInfo.prokiiiID]]
                    try await MongoDBManager.shared.insertParticipant(participant!)
                } else {
                    // If participant document exists, update the members
                    var members = participant!["members"] as? [String] ?? []
                    if !members.contains(userInfo.prokiiiID) {
                        members.append(userInfo.prokiiiID)
                        let update: Document = ["$set": ["members": members]]
                        try await MongoDBManager.shared.getCollection(collectionName: "participants")?.updateOne(where: participantQuery, to: update)
                    }
                }

                alertMessage = "Successfully joined the event!"
                showAlert = true
            } catch {
                // Handle any errors during the join process
                alertMessage = "Failed to join event: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}

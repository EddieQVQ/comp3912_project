//
//  EventDetailView.swift
//  prokiii
//
//  Created by Eddie XU on 2024-07-29.
//

import SwiftUI
import MongoKitten

// A view for displaying the details of an event
struct EventDetailView: View {
    @State var event: Document // The event document to display
    @State private var showEditEventView: Bool = false // State property to control the presentation of the EditEventView
    @State private var showJoinEventView: Bool = false // State property to control the presentation of the JoinEventView
    @State private var participants: [Document] = [] // State property to hold the list of participants
    @EnvironmentObject var userInfo: UserInfo // EnvironmentObject to access user information
    @State private var userHasJoined: Bool = false // State property to track if the user has joined the event
    @State private var userTeamName: String? // State property to hold the team name of the user

    var body: some View {
        VStack(spacing: 20) {
            // Display event details section
            VStack(spacing: 10) {
                Text(event["title"] as? String ?? "Untitled Event")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 10)

                Text("Organized by \(event["organizer"] as? String ?? "Unknown Organizer")")
                    .font(.title2)
                    .foregroundColor(.gray)

                Text(event["location"] as? String ?? "No Location")
                    .font(.title3)
                    .padding(.top, 10)

                if let date = event["date"] as? Date {
                    Text("Date & Time: \(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short))")
                        .font(.title3)
                } else {
                    Text("No Date")
                        .font(.title3)
                }

                Text(event["description"] as? String ?? "No Description")
                    .font(.body)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(10)
            .shadow(radius: 2)
            .frame(maxWidth: .infinity)

            // List of participants and their teams
            List {
                ForEach(participants, id: \.self) { participant in
                    VStack(alignment: .leading) {
                        Text("Team: \(participant["teamName"] as? String ?? "Unnamed Team")")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 5)
                        
                        if let teamMembers = participant["members"] as? [String] {
                            ForEach(teamMembers, id: \.self) { member in
                                Text("Prokiii ID: \(member)")
                                    .font(.subheadline)
                                    .padding(.leading, 10)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .shadow(radius: 2)
                    .frame(maxWidth: .infinity)
                }
            }
            .listStyle(PlainListStyle())

            // Display appropriate buttons based on user role and event state
            if event["creatorEmail"] as? String == userInfo.email {
                Button(action: {
                    showEditEventView.toggle()
                }) {
                    Text("Edit Event")
                        .fontWeight(.semibold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
            } else {
                if userHasJoined {
                    Button(action: {
                        leaveEvent() // Call the leaveEvent method
                    }) {
                        Text("Cancel")
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                } else {
                    Button(action: {
                        showJoinEventView.toggle() // Toggle the JoinEventView
                    }) {
                        Text("Join")
                            .fontWeight(.semibold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showEditEventView) {
            EditEventView(event: $event) // Present the EditEventView
        }
        .sheet(isPresented: $showJoinEventView) {
            JoinEventView(event: event)
                .environmentObject(userInfo) // Present the JoinEventView
        }
        .onAppear {
            fetchParticipants() // Fetch participants when the view appears
            checkIfUserHasJoined() // Check if the user has joined the event
        }
    }

    // Method to fetch participants from the database
    private func fetchParticipants() {
        Task {
            do {
                if let eventId = event["_id"] as? ObjectId {
                    participants = try await MongoDBManager.shared.fetchParticipants(for: eventId)
                }
            } catch {
                print("Failed to fetch participants: \(error)")
            }
        }
    }

    // Method to check if the current user has joined the event
    private func checkIfUserHasJoined() {
        Task {
            do {
                if let eventId = event["_id"] as? ObjectId {
                    if let participant = try await MongoDBManager.shared.getParticipant(for: eventId, prokiiiID: userInfo.prokiiiID) {
                        userHasJoined = true
                        userTeamName = participant["teamName"] as? String
                    } else {
                        userHasJoined = false
                        userTeamName = nil
                    }
                }
            } catch {
                print("Failed to check if user has joined: \(error)")
            }
        }
    }

    // Method to remove the user from the event
    private func leaveEvent() {
        Task {
            do {
                if let eventId = event["_id"] as? ObjectId {
                    try await MongoDBManager.shared.removeParticipant(from: eventId, prokiiiID: userInfo.prokiiiID)
                    userHasJoined = false
                    userTeamName = nil
                    fetchParticipants()
                }
            } catch {
                print("Failed to leave event: \(error)")
            }
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(event: Document())
            .environmentObject(UserInfo())
    }
}

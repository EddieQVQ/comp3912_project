//
//  CreateEventView.swift
//  prokiii
//
//  Created by Eddie XU on 2024-07-29.
//

import SwiftUI
import MongoKitten

// A view for creating a new event
struct CreateEventView: View {
    @Environment(\.presentationMode) var presentationMode // Environment property to control the presentation mode
    @State private var eventTitle: String = "" // State property for event title
    @State private var organizer: String = "" // State property for organizer
    @State private var location: String = "" // State property for location
    @State private var date: Date = Date() // State property for event date
    @State private var prize1: String = "" // State property for the first prize
    @State private var prize2: String = "" // State property for the second prize
    @State private var prize3: String = "" // State property for the third prize
    @State private var description: String = "" // State property for event description
    @State private var showAlert: Bool = false // State property to control alert presentation
    @State private var alertMessage: String = "" // State property for alert message
    @EnvironmentObject var userInfo: UserInfo // EnvironmentObject to access user information

    var body: some View {
        NavigationView {
            Form {
                // Section for entering event details
                Section(header: Text("Event Details")) {
                    TextField("Event Title", text: $eventTitle)
                    TextField("Organizer", text: $organizer)
                    TextField("Location", text: $location)
                    DatePicker("Date and Time", selection: $date, displayedComponents: [.date, .hourAndMinute])
                    TextField("1st Prize", text: $prize1)
                    TextField("2nd Prize", text: $prize2)
                    TextField("3rd Prize", text: $prize3)
                    TextField("Description", text: $description)
                }

                // Section for the create event button
                Section {
                    Button(action: {
                        createEvent() // Call the createEvent method
                    }) {
                        Text("Create Event")
                    }
                }
            }
            .navigationTitle("Create Event")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Event Creation"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    // Method to create an event
    private func createEvent() {
        // Validate inputs
        guard !eventTitle.isEmpty, !organizer.isEmpty else {
            alertMessage = "Please fill in all required fields."
            showAlert = true
            return
        }

        // Create event document
        let event: Document = [
            "title": eventTitle,
            "organizer": organizer,
            "creatorEmail": userInfo.email, 
            "location": location,
            "date": date,
            "prizes": ["1st": prize1, "2nd": prize2, "3rd": prize3],
            "description": description,
        ]

        // Insert the event document into the MongoDB collection
        Task {
            do {
                try await MongoDBManager.shared.insertEvent(event)
                alertMessage = "Event created successfully!"
                showAlert = true
                presentationMode.wrappedValue.dismiss()
            } catch {
                alertMessage = "Failed to create event: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}

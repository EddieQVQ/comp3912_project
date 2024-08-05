import SwiftUI
import MongoKitten

// A view for editing the details of an event
struct EditEventView: View {
    @Binding var event: Document // Binding to the event document to be edited
    @State private var eventTitle: String // State property to hold the event title
    @State private var organizer: String // State property to hold the organizer name
    @State private var location: String // State property to hold the event location
    @State private var date: Date // State property to hold the event date
    @State private var prize1: String // State property to hold the first prize
    @State private var prize2: String // State property to hold the second prize
    @State private var prize3: String // State property to hold the third prize
    @State private var description: String // State property to hold the event description
    @State private var showAlert: Bool = false // State property to control the display of an alert
    @State private var alertMessage: String = "" // State property to hold the alert message

    // Custom initializer to set initial values from the event document
    init(event: Binding<Document>) {
        self._event = event
        self._eventTitle = State(initialValue: event.wrappedValue["title"] as? String ?? "")
        self._organizer = State(initialValue: event.wrappedValue["organizer"] as? String ?? "")
        self._location = State(initialValue: event.wrappedValue["location"] as? String ?? "")
        self._date = State(initialValue: (event.wrappedValue["date"] as? Date) ?? Date())
        self._prize1 = State(initialValue: (event.wrappedValue["prizes"] as? Document)?["1st"] as? String ?? "")
        self._prize2 = State(initialValue: (event.wrappedValue["prizes"] as? Document)?["2nd"] as? String ?? "")
        self._prize3 = State(initialValue: (event.wrappedValue["prizes"] as? Document)?["3rd"] as? String ?? "")
        self._description = State(initialValue: event.wrappedValue["description"] as? String ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                // Section to input event details
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

                // Section to update the event
                Section {
                    Button(action: {
                        updateEvent() // Call the updateEvent method
                    }) {
                        Text("Update Event")
                    }
                }
            }
            .navigationTitle("Edit Event")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Event Update"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }

    // Method to update the event in the database
    private func updateEvent() {
        // Update event document with new values
        event["title"] = eventTitle
        event["organizer"] = organizer
        event["location"] = location
        event["date"] = date
        event["prizes"] = ["1st": prize1, "2nd": prize2, "3rd": prize3]
        event["description"] = description

        Task {
            do {
                // Ensure the event has a valid ID before updating
                guard let eventId = event["_id"] else { return }
                // Update the event document in the database
                try await MongoDBManager.shared.getCollection(collectionName: "events")?.updateOne(where: "_id" == eventId, to: event)
                alertMessage = "Event updated successfully!"
                showAlert = true
            } catch {
                alertMessage = "Failed to update event: \(error.localizedDescription)"
                showAlert = true
            }
        }
    }
}


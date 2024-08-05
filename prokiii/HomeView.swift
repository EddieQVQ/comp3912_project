//
//  HomeView.swift
//  prokiii
//
//  Created by Eddie XU on 2024-07-15.
//

import SwiftUI
import MongoKitten

struct HomeView: View {
    @Binding var isLoggedIn: Bool // Binding to manage login status
    @State private var events: [Document] = [] // State variable to store fetched events
    @State private var showCreateEventView: Bool = false // State variable to manage event creation view

    var body: some View {
        TabView {
            NavigationView {
                ScrollView {
                    // LazyVGrid to display events in a grid layout
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                        ForEach(events, id: \.self) { event in
                            NavigationLink(destination: EventDetailView(event: event)) {
                                EventCardView(event: event) // Display each event using EventCardView
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Home") // Set navigation title
                .navigationBarItems(trailing: Button(action: {
                    showCreateEventView.toggle() // Toggle event creation view
                }) {
                    Image(systemName: "plus") // Button to create a new event
                })
                .sheet(isPresented: $showCreateEventView) {
                    CreateEventView() // Present CreateEventView as a sheet
                }
                .onAppear {
                    fetchEvents() // Fetch events when the view appears
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("Home")
            }

            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }

            ProfileView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
        }
    }

    // Function to fetch events from the MongoDB
    private func fetchEvents() {
        Task {
            do {
                events = try await MongoDBManager.shared.fetchEvents() // Fetch events from the database
            } catch {
                print("Failed to fetch events: \(error)") // Handle errors during fetch
            }
        }
    }
}

struct EventCardView: View {
    let event: Document // Event data

    var body: some View {
        VStack {
            Text(event["title"] as? String ?? "Untitled Event")
                .font(.headline) // Event title
            if let date = event["date"] as? Date {
                Text(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .short))
                    .font(.subheadline) // Event date
            } else {
                Text("No Date")
                    .font(.subheadline)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2)) 
        .cornerRadius(10)
    }
}



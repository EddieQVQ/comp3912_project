//
//  MongoDBManager.swift
//  prokiii
//
//  Created by Eddie XU on 2024-07-15.
//

import Foundation
import MongoKitten

// Singleton class to manage MongoDB operations
class MongoDBManager {
    static let shared = MongoDBManager()
    var client: MongoDatabase?

    // Private initializer to set up MongoDB connection
    private init() {
        do {
            let settings = try ConnectionSettings("")
            let cluster = try MongoCluster(lazyConnectingTo: settings)
            client = cluster["Users"]
        } catch {
            print("Failed to connect to MongoDB: \(error)")
        }
    }

    /// Retrieve a specific collection from the database
    /// - Parameter collectionName: The name of the collection to retrieve
    /// - Returns: The MongoCollection if available, otherwise nil
    func getCollection(collectionName: String) -> MongoCollection? {
        guard let client = client else { return nil }
        return client[collectionName]
    }

    /// Upload a profile image for a user
    /// - Parameters:
    ///   - userId: The user ID
    ///   - imageData: The image data to upload
    ///   - isGoogleUser: A flag indicating if the user is authenticated via Google
    /// - Throws: An error if the operation fails
    func uploadProfileImage(for userId: String, imageData: Data, isGoogleUser: Bool) async throws {
        guard let collection = getCollection(collectionName: "users") else {
            throw NSError(domain: "MongoDB", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to access the users collection."])
        }
        
        let filter: Document = isGoogleUser ? ["_id": userId] : ["prokiiiID": userId]
        let base64String = imageData.base64EncodedString()
        let update: Document = ["$set": ["profileImage": base64String]]
        
        try await collection.updateOne(where: filter, to: update)
    }

    /// Fetch the profile image for a user
    /// - Parameters:
    ///   - userId: The user ID
    ///   - isGoogleUser: A flag indicating if the user is authenticated via Google
    /// - Returns: The image data if available, otherwise nil
    /// - Throws: An error if the operation fails
    func fetchProfileImage(for userId: String, isGoogleUser: Bool) async throws -> Data? {
        guard let collection = getCollection(collectionName: "users") else {
            throw NSError(domain: "MongoDB", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to access the users collection."])
        }
        
        let filter: Document = isGoogleUser ? ["_id": userId] : ["prokiiiID": userId]
        let userDocument = try await collection.findOne(filter)
        
        if let base64String = userDocument?["profileImage"] as? String {
            return Data(base64Encoded: base64String)
        }
        
        return nil
    }

    /// Fetch the user document for a user
    /// - Parameters:
    ///   - userId: The user ID
    ///   - isGoogleUser: A flag indicating if the user is authenticated via Google
    /// - Returns: The user document if available, otherwise nil
    /// - Throws: An error if the operation fails
    func fetchUserDocument(for userId: String, isGoogleUser: Bool) async throws -> Document? {
        guard let collection = getCollection(collectionName: "users") else {
            throw NSError(domain: "MongoDB", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to access the users collection."])
        }
        
        let filter: Document = isGoogleUser ? ["_id": userId] : ["prokiiiID": userId]
        return try await collection.findOne(filter)
    }

    /// Update the Prokiii ID for a user
    /// - Parameters:
    ///   - userId: The user ID
    ///   - newProkiiiID: The new Prokiii ID
    ///   - isGoogleUser: A flag indicating if the user is authenticated via Google
    /// - Throws: An error if the operation fails
    func updateProkiiiID(for userId: String, newProkiiiID: String, isGoogleUser: Bool) async throws {
        guard let collection = getCollection(collectionName: "users") else {
            throw NSError(domain: "MongoDB", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to access the users collection."])
        }

        let filter: Document = isGoogleUser ? ["_id": userId] : ["prokiiiID": userId]
        let update: Document = ["$set": ["prokiiiID": newProkiiiID]]
        
        try await collection.updateOne(where: filter, to: update)
    }
    
    // Event-related methods

    /// Insert a new event
    /// - Parameter event: The event document to insert
    /// - Throws: An error if the operation fails
    func insertEvent(_ event: Document) async throws {
        guard let collection = getCollection(collectionName: "events") else {
            throw NSError(domain: "MongoDB", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to access the events collection."])
        }
        try await collection.insert(event)
    }

    /// Fetch all events
    /// - Returns: An array of event documents
    /// - Throws: An error if the operation fails
    func fetchEvents() async throws -> [Document] {
        guard let collection = getCollection(collectionName: "events") else {
            throw NSError(domain: "MongoDB", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to access the events collection."])
        }
        var events: [Document] = []
        for try await event in collection.find() {
            events.append(event)
        }
        return events
    }

    /// Fetch participants for a specific event
    /// - Parameter eventID: The ID of the event
    /// - Returns: An array of participant documents
    /// - Throws: An error if the operation fails
    func fetchParticipants(for eventID: ObjectId) async throws -> [Document] {
        guard let collection = getCollection(collectionName: "participants") else {
            throw NSError(domain: "MongoDB", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to access the participants collection."])
        }
        var participants: [Document] = []
        let query: Document = ["eventID": eventID]
        for try await participant in collection.find(query) {
            participants.append(participant)
        }
        return participants
    }

    /// Insert a new participant
    /// - Parameter participant: The participant document to insert
    /// - Throws: An error if the operation fails
    func insertParticipant(_ participant: Document) async throws {
        guard let collection = getCollection(collectionName: "participants") else {
            throw NSError(domain: "MongoDB", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to access the participants collection."])
        }
        try await collection.insert(participant)
    }

    /// Get a participant document for a specific event and user
    /// - Parameters:
    ///   - eventID: The ID of the event
    ///   - prokiiiID: The Prokiii ID of the user
    /// - Returns: The participant document if available, otherwise nil
    /// - Throws: An error if the operation fails
    func getParticipant(for eventID: ObjectId, prokiiiID: String) async throws -> Document? {
        guard let collection = getCollection(collectionName: "participants") else {
            throw NSError(domain: "MongoDB", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to access the participants collection."])
        }
        let query: Document = ["eventID": eventID, "members": ["$in": [prokiiiID]]]
        return try await collection.findOne(query)
    }

    /// Remove a participant from an event
    /// - Parameters:
    ///   - eventID: The ID of the event
    ///   - prokiiiID: The Prokiii ID of the user
    /// - Throws: An error if the operation fails
    func removeParticipant(from eventID: ObjectId, prokiiiID: String) async throws {
        guard let collection = getCollection(collectionName: "participants") else {
            throw NSError(domain: "MongoDB", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to access the participants collection."])
        }
        let query: Document = ["eventID": eventID, "members": ["$in": [prokiiiID]]]
        if let participant = try await collection.findOne(query) {
            var members = participant["members"] as? [String] ?? []
            members.removeAll { $0 == prokiiiID }
            if members.isEmpty {
                try await collection.deleteOne(where: query)
            } else {
                let update: Document = ["$set": ["members": members]]
                try await collection.updateOne(where: query, to: update)
            }
        }
    }
}


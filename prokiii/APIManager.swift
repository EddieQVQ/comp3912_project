//
//  APIManager.swift
//  prokiii
//
//  Created by Eddie XU on 2024-07-23.
//
// RIOT Developer API: https://developer.riotgames.com/apis
// Warning: Riot API keys expire every 24 hours. If the API key expires, visit [Riot Developer Portal](https://developer.riotgames.com/) to regenerate a new key, then replace the key in `ApiManager.swift`.

import Foundation

// Structure to hold champion information
struct ChampionInfo: Codable {
    let maxNewPlayerLevel: Int
    let freeChampionIdsForNewPlayers: [Int]
    let freeChampionIds: [Int]
}

// Enum to define possible API errors
enum ApiError: Error {
    case invalidResponse
    case noData
    case failedRequest
    case invalidData
}

// Singleton class to manage API operations
class ApiManager {
    static let shared = ApiManager()
    private let apiKey = "RGAPI-5f412e1b-9155-48c4-9283-4883f23fd97e"
    private let championRotationURL = "https://na1.api.riotgames.com/lol/platform/v3/champion-rotations"

    /// Fetch champion rotations from the Riot Games API
    /// - Parameter completion: A closure to handle the result of the API call
    func getChampionRotations(completion: @escaping (Result<ChampionInfo, ApiError>) -> Void) {
        guard let url = URL(string: "\(championRotationURL)?api_key=\(apiKey)") else {
            print("Invalid URL")
            completion(.failure(.invalidData))
            return
        }

        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "X-Riot-Token")

        print("Request URL: \(url.absoluteString)")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request failed with error: \(error)")
                completion(.failure(.failedRequest))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response received")
                completion(.failure(.invalidResponse))
                return
            }

            print("HTTP Response Code: \(httpResponse.statusCode)")

            if httpResponse.statusCode == 200 {
                guard let data = data else {
                    print("No data received")
                    completion(.failure(.noData))
                    return
                }

                do {
                    let championInfo = try JSONDecoder().decode(ChampionInfo.self, from: data)
                    completion(.success(championInfo))
                } catch {
                    print("Failed to decode data: \(error)")
                    completion(.failure(.invalidData))
                }
            } else {
                print("HTTP Response Code: \(httpResponse.statusCode)")
                if let data = data, let responseBody = String(data: data, encoding: .utf8) {
                    print("Response Body: \(responseBody)")
                }
                completion(.failure(.invalidResponse))
            }
        }
        task.resume()
    }
}

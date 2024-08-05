//
//  SearchView.swift
//  prokiii
//
//  Created by Eddie XU on 2024-07-23.
//
// RIOT Developer Doc: https://developer.riotgames.com/docs/lol
// Data Dragon versions: https://ddragon.leagueoflegends.com/api/versions.json
// Latest ddragon Version: 14.14.1


import SwiftUI

// Function to generate champion image URL based on champion ID
func championImageUrl(for championId: Int) -> String {
    let baseUrl = "https://ddragon.leagueoflegends.com/cdn/14.14.1/img/champion/"
    return "\(baseUrl)\(championNames[championId] ?? "Unknown").png"
}

// Champion Names Mapping
let championNames: [Int: String] = [
    1: "Annie", 2: "Olaf", 3: "Galio", 4: "TwistedFate", 5: "XinZhao",
    6: "Urgot", 7: "Leblanc", 8: "Vladimir", 9: "Fiddlesticks", 10: "Kayle",
    11: "MasterYi", 12: "Alistar", 13: "Ryze", 14: "Sion", 15: "Sivir",
    16: "Soraka", 17: "Teemo", 18: "Tristana", 19: "Warwick", 20: "Nunu",
    21: "MissFortune", 22: "Ashe", 23: "Tryndamere", 24: "Jax", 25: "Morgana",
    26: "Zilean", 27: "Singed", 28: "Evelynn", 29: "Twitch", 30: "Karthus",
    31: "Chogath", 32: "Amumu", 33: "Rammus", 34: "Anivia", 35: "Shaco",
    36: "DrMundo", 37: "Sona", 38: "Kassadin", 39: "Irelia", 40: "Janna",
    41: "Gangplank", 42: "Corki", 43: "Karma", 44: "Taric", 45: "Veigar",
    48: "Trundle", 50: "Swain", 51: "Caitlyn", 53: "Blitzcrank", 54: "Malphite",
    55: "Katarina", 56: "Nocturne", 57: "Maokai", 58: "Renekton", 59: "JarvanIV",
    60: "Elise", 61: "Orianna", 62: "MonkeyKing", 63: "Brand", 64: "LeeSin",
    67: "Vayne", 68: "Rumble", 69: "Cassiopeia", 72: "Skarner", 74: "Heimerdinger",
    75: "Nasus", 76: "Nidalee", 77: "Udyr", 78: "Poppy", 79: "Gragas",
    80: "Pantheon", 81: "Ezreal", 82: "Mordekaiser", 83: "Yorick", 84: "Akali",
    85: "Kennen", 86: "Garen", 89: "Leona", 90: "Malzahar", 91: "Talon",
    92: "Riven", 96: "KogMaw", 98: "Shen", 99: "Lux", 101: "Xerath",
    102: "Shyvana", 103: "Ahri", 104: "Graves", 105: "Fizz", 106: "Volibear",
    107: "Rengar", 110: "Varus", 111: "Nautilus", 112: "Viktor", 113: "Sejuani",
    114: "Fiora", 115: "Ziggs", 117: "Lulu", 119: "Draven", 120: "Hecarim",
    121: "Khazix", 122: "Darius", 126: "Jayce", 127: "Lissandra", 131: "Diana",
    133: "Quinn", 134: "Syndra", 136: "AurelionSol", 141: "Kayn", 142: "Zoe",
    143: "Zyra", 145: "Kaisa", 147: "Seraphine", 150: "Gnar", 154: "Zac",
    157: "Yasuo", 161: "Velkoz", 163: "Taliyah", 164: "Camille", 166: "Akshan",
    200: "Belveth", 201: "Braum", 202: "Jhin", 203: "Kindred", 221: "Zeri",
    222: "Jinx", 223: "TahmKench", 234: "Viego", 235: "Senna", 236: "Lucian",
    238: "Zed", 240: "Kled", 245: "Ekko", 246: "Qiyana", 254: "Vi",
    266: "Aatrox", 267: "Nami", 268: "Azir", 350: "Yuumi", 360: "Samira",
    412: "Thresh", 420: "Illaoi", 421: "RekSai", 427: "Ivern", 429: "Kalista",
    432: "Bard", 497: "Rakan", 498: "Xayah", 516: "Ornn", 517: "Sylas",
    518: "Neeko", 523: "Aphelios", 526: "Rell", 555: "Pyke", 711: "Vex",
    777: "Yone", 875: "Sett", 876: "Lillia", 887: "Gwen", 888: "Renata"
]

struct SearchView: View {
    @State private var championInfo: ChampionInfo? // State variable to store champion info
    @State private var isLoading: Bool = true // State variable to track loading status
    @State private var showError: Bool = false // State variable to track error status

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading champion rotation...")
                    .padding()
            } else if showError {
                Text("Failed to load champion rotation. Please try again later.")
                    .foregroundColor(.red)
                    .padding()
            } else if let championInfo = championInfo {
                VStack(spacing: 20) {
                    championRotationCard(title: "Free Champion Rotation", championIds: championInfo.freeChampionIds)
                    championRotationCard(title: "Free Champion Rotation for New Players", championIds: championInfo.freeChampionIdsForNewPlayers)
                }
                .padding(.top, 20)
            }
        }
        .padding()
        .onAppear {
            fetchChampionRotations() // Fetch champion rotations on view appear
        }
    }

    // Function to create a view for champion rotation card
    private func championRotationCard(title: String, championIds: [Int]) -> some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding(.bottom, 5)
                .frame(maxWidth: .infinity, alignment: .center)

            ScrollView {
                VStack {
                    ForEach(0..<((championIds.count + 2) / 3), id: \.self) { row in
                        HStack {
                            ForEach(0..<3, id: \.self) { column in
                                let index = row * 3 + column
                                if index < championIds.count {
                                    let championId = championIds[index]
                                    if let championName = championNames[championId] {
                                        VStack {
                                            let imageUrl = championImageUrl(for: championId)
                                            if let url = URL(string: imageUrl) {
                                                AsyncImage(url: url) { phase in
                                                    switch phase {
                                                    case .empty:
                                                        ProgressView()
                                                    case .success(let image):
                                                        image.resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 50, height: 50)
                                                    case .failure:
                                                        Image(systemName: "xmark.circle")
                                                    @unknown default:
                                                        EmptyView()
                                                    }
                                                }
                                                .frame(width: 50, height: 50)
                                                .clipShape(Circle())
                                            }
                                            Text(championName)
                                                .font(.caption)
                                                .frame(maxWidth: .infinity)
                                        }
                                        .frame(width: 80)
                                    } else {
                                        Spacer()
                                    }
                                } else {
                                    Spacer()
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .padding()
            }
            .frame(height: 200)
            .background(Color.white)
            .cornerRadius(8)
            .shadow(radius: 2)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
    }

    // Function to fetch champion rotations
    private func fetchChampionRotations() {
        ApiManager.shared.getChampionRotations { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let championInfo):
                    self.championInfo = championInfo
                case .failure(let error):
                    print("Error fetching champion rotation: \(error)")
                    showError = true
                }
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

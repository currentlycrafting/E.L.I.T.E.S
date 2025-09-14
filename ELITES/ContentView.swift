//
//  ContentView.swift
//  ELITES
//
//  Created by Someone Guy on 9/14/25.
//

import SwiftUI

// MARK: - Theme
struct AppTheme {
    static let background = Color(red: 0.1, green: 0.1, blue: 0.12)
    static let card = Color(red: 0.18, green: 0.18, blue: 0.20)
    static let textPrimary = Color.white
    static let textSecondary = Color(white: 0.75)
    static let textInput = Color.white
    static let buttonText = Color.white
    static let highlight = Color(red: 1.0, green: 0.84, blue: 0.0) // professional gold
}

// MARK: - Neumorphic Components
struct NeumorphicButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppTheme.buttonText)
                }
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppTheme.buttonText)
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
            .frame(maxWidth: .infinity)
            .background(AppTheme.card)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.6), radius: 6, x: 6, y: 6)
            .shadow(color: .white.opacity(0.02), radius: 6, x: -6, y: -1)
        }
        .buttonStyle(.plain)
    }
}

struct NeumorphicTextField: View {
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    var placeholderColor: Color = Color.white.opacity(0.6)
    
    var body: some View {
        ZStack(alignment: .leading) {
            AppTheme.card
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.6), radius: 6, x: 6, y: 6)
                .shadow(color: .white.opacity(0.02), radius: 6, x: -6, y: -1)
            
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(placeholderColor)
                    .padding(.leading, 14)
            }
            
            if isSecure {
                SecureField("", text: $text)
                    .padding()
                    .foregroundColor(AppTheme.textInput)
            } else {
                TextField("", text: $text)
                    .padding()
                    .foregroundColor(AppTheme.textInput)
                    .autocapitalization(.none)
            }
        }
        .frame(height: 48)
    }
}

// MARK: - Models
struct Player: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var currentElo: Int
    
    init(id: UUID = UUID(), name: String, currentElo: Int = 1000) {
        self.id = id
        self.name = name
        self.currentElo = currentElo
    }
}

struct Match: Identifiable {
    let id = UUID()
    var player1: Player
    var player2: Player
    var winner: Player?
}

// MARK: - Persistence Manager
class PersistenceManager {
    static let shared = PersistenceManager()
    private let key = "savedPlayers.v1"
    
    private init() {}
    
    func savePlayers(_ players: [Player]) {
        if let data = try? JSONEncoder().encode(players) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    func loadPlayers() -> [Player] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Player].self, from: data) else { return [] }
        return decoded
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - Elo Service
class EloService {
    /// Classic Elo update (K-factor default 32)
    static func updateElo(winner: inout Player, loser: inout Player, kFactor: Int = 32) {
        let expectedWinner = 1 / (1 + pow(10, Double(loser.currentElo - winner.currentElo)/400))
        let expectedLoser = 1 / (1 + pow(10, Double(winner.currentElo - loser.currentElo)/400))
        winner.currentElo += Int(Double(kFactor) * (1 - expectedWinner))
        loser.currentElo += Int(Double(kFactor) * (0 - expectedLoser))
    }
}

// MARK: - Tournament Service
class TournamentService {
    /// Returns matches and an array of bye players that auto-advance this round.
    static func generateMatches(from players: [Player]) -> ([Match], [Player]) {
        var shuffled = players.shuffled()
        let n = shuffled.count
        guard n > 1 else { return ([], []) }
        
        // Compute next power of two
        func nextPowerOfTwo(_ x: Int) -> Int {
            var pow = 1
            while pow < x { pow <<= 1 }
            return pow
        }
        
        let target = nextPowerOfTwo(n)
        let numByes = target - n
        var byePlayers: [Player] = []
        
        if numByes > 0 {
            for _ in 0..<numByes {
                if shuffled.isEmpty { break }
                let idx = Int.random(in: 0..<shuffled.count)
                byePlayers.append(shuffled.remove(at: idx))
            }
        }
        
        var matches: [Match] = []
        for i in stride(from: 0, to: shuffled.count, by: 2) {
            if i + 1 < shuffled.count {
                matches.append(Match(player1: shuffled[i], player2: shuffled[i+1], winner: nil))
            }
        }
        return (matches, byePlayers)
    }
}

// MARK: - Leaderboard View
struct LeaderboardView: View {
    @Binding var players: [Player]
    var sorted: [Player] { players.sorted { $0.currentElo > $1.currentElo } }
    
    var body: some View {
        ZStack {
            AppTheme.background.edgesIgnoringSafeArea(.all)
            VStack(spacing: 12) {
                Text("Leaderboard")
                    .font(.title2).bold()
                    .foregroundColor(AppTheme.textPrimary)
                    .padding(.top)
                
                List {
                    ForEach(Array(sorted.enumerated()), id: \.1.id) { idx, p in
                        HStack {
                            Text("\(idx + 1).")
                                .frame(width: 30, alignment: .leading)
                                .foregroundColor(AppTheme.textSecondary)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(p.name)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppTheme.textPrimary)
                                Text("Elo: \(p.currentElo)")
                                    .font(.caption)
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 8)
                        .listRowBackground(AppTheme.card)
                    }
                }
                .listStyle(.plain)
                .background(AppTheme.background)
            }
            .padding()
        }
    }
}

// MARK: - ContentView
struct ContentView: View { var body: some View { HomeView() } }

// MARK: - Home View
struct HomeView: View {
    @State private var players: [Player] = PersistenceManager.shared.loadPlayers()
    @State private var newName: String = ""
    @State private var rounds: String = "3"
    @State private var startActive: Bool = false
    @State private var cappedRoundsForNav: Int = 1
    @State private var showClearConfirm = false
    @State private var showResetConfirm = false
    
    // MARK: - Rounds calculation using log2 (single elimination)
    private var maxRounds: Int {
        // Maximum rounds for single-elimination: ceil(log2(players))
        guard players.count > 1 else { return 1 }
        return Int(ceil(log2(Double(players.count))))
    }

    private var minRounds: Int {
        // Minimum rounds required to ensure a winner: ceil(log2(players))
        guard players.count > 1 else { return 1 }
        return Int(ceil(log2(Double(players.count))))
    }
    
    
    private var roundsInt: Int? { Int(rounds) }
    
    private var roundsWarning: String? {
        guard let r = roundsInt else { return "Enter a valid number" }
        if r < minRounds { return "Minimum rounds for \(players.count) players is \(minRounds)" }
        if r > maxRounds { return "Maximum rounds for \(players.count) players is \(maxRounds)" }
        return nil
    }
    
    private func savePlayers() { PersistenceManager.shared.savePlayers(players) }
    private func clearAllPlayers() { players.removeAll(); savePlayers() }
    private func resetElos() { players = players.map { Player(id: $0.id, name: $0.name, currentElo: 1000) }; savePlayers() }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.edgesIgnoringSafeArea(.all)
                VStack(spacing: 18) {
                    
                    // Header
                    HStack(spacing: 12) {
                        Image("ELITE_Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 64, height: 64)
                            .cornerRadius(8)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ELITE Tournament")
                                .font(.title2).bold()
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Lightweight Elo tracking & rounds")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                        Spacer()
                        NavigationLink(destination: LeaderboardView(players: $players)) {
                            Image(systemName: "list.number")
                                .foregroundColor(AppTheme.buttonText)
                                .padding(8)
                                .background(AppTheme.card)
                                .cornerRadius(8)
                        }
                    }
                    .padding()
                    .background(AppTheme.card)
                    .cornerRadius(12)
                    
                    // Player input
                    NeumorphicTextField(
                        placeholder: "Player Name",
                        text: $newName,
                        isSecure: false,
                        placeholderColor: Color.white.opacity(0.65)
                    )
                    
                    HStack(spacing: 12) {
                        NeumorphicButton(title: "Add Player", icon: "plus") {
                            let name = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !name.isEmpty else { return }
                            players.append(Player(name: name))
                            newName = ""
                            savePlayers()
                        }
                        
                        NeumorphicButton(title: "Reset Elos", icon: "arrow.counterclockwise") {
                            showResetConfirm = true
                        }
                        .confirmationDialog("Reset Elo ratings to 1000 for all players?", isPresented: $showResetConfirm, titleVisibility: .visible) {
                            Button("Reset Elo", role: .destructive) { resetElos() }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                    
                    // Rounds input
                    HStack(spacing: 12) {
                        Text("Rounds:")
                            .foregroundColor(AppTheme.textPrimary)
                        NeumorphicTextField(
                            placeholder: "",
                            text: $rounds,
                            isSecure: false,
                            placeholderColor: Color.white.opacity(0.65)
                        )
                        .frame(width: 84)
                        Spacer()
                        Button(action: { rounds = String(maxRounds) }) {
                            Text("Set Max (\(maxRounds))")
                                .font(.caption)
                                .foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    
                    if let warning = roundsWarning {
                        Text(warning)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 2)
                    } else {
                        Text("Valid rounds: \(minRounds) to \(maxRounds) for \(players.count) players")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 2)
                    }
                    
                    // Player list
                    List {
                        ForEach(players) { player in
                            HStack {
                                Text(player.name)
                                    .foregroundColor(AppTheme.textPrimary)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(player.currentElo)")
                                    .foregroundColor(AppTheme.textSecondary)
                            }
                            .padding(.vertical, 6)
                            .listRowBackground(AppTheme.card)
                        }
                        .onDelete { idx in
                            players.remove(atOffsets: idx)
                            savePlayers()
                        }
                    }
                    .listStyle(.plain)
                    .frame(maxHeight: 220)
                    
                    // Start / Clear
                    HStack(spacing: 12) {
                        if players.count > 1 {
                            Button(action: {
                                if let r = roundsInt, roundsWarning == nil {
                                    cappedRoundsForNav = r
                                    startActive = true
                                }
                            }) {
                                Text("Start Tournament")
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(roundsWarning == nil ? Color.green : Color.gray)
                                    .foregroundColor(.black)
                                    .cornerRadius(12)
                            }
                            .buttonStyle(.plain)
                            .disabled(roundsWarning != nil)
                        } else {
                            Text("Add at least 2 players")
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                        }
                        
                        Button(role: .destructive) {
                            showClearConfirm = true
                        } label: {
                            Text("Clear All")
                                .frame(width: 110)
                                .padding(.vertical, 12)
                                .background(AppTheme.card)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        .confirmationDialog("Clear all players? This cannot be undone.", isPresented: $showClearConfirm, titleVisibility: .visible) {
                            Button("Clear All", role: .destructive) { clearAllPlayers() }
                            Button("Cancel", role: .cancel) {}
                        }
                    }
                    
                    Spacer()
                    
                    // Hidden NavigationLink
                    NavigationLink(
                        destination: TournamentView(
                            players: players,
                            totalRounds: cappedRoundsForNav,
                            onUpdatePlayers: { updated in
                                players = updated
                                savePlayers()
                            }
                        ),
                        isActive: $startActive
                    ) { EmptyView() }
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Tournament View
struct TournamentView: View {
    @State var players: [Player]                    // active players this round
    let totalRounds: Int
    let onUpdatePlayers: ([Player]) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var matches: [Match] = []
    @State private var byePlayers: [Player] = []
    @State private var currentRound: Int = 1
    @State private var allPlayers: [Player] = []    // master copy for persistence
    @State private var byeHistory: Set<UUID> = []   // track who got byes

    private var roundResolved: Bool {
        matches.allSatisfy { $0.winner != nil }
    }

    private var advancingPlayersAfterThisRound: [Player] {
        var winners = matches.compactMap { $0.winner }
        winners.append(contentsOf: byePlayers)
        return winners
    }

    var body: some View {
        ZStack {
            AppTheme.background.edgesIgnoringSafeArea(.all)

            VStack(spacing: 16) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text("Round \(currentRound) of \(totalRounds)")
                            .font(.headline)
                            .foregroundColor(AppTheme.textPrimary)
                        Text("Players Remaining: \(players.count)")
                            .font(.caption)
                            .foregroundColor(AppTheme.textSecondary)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)

                // Byes
                if !byePlayers.isEmpty {
                    HStack {
                        Text("Byes:")
                            .foregroundColor(AppTheme.textSecondary)
                            .font(.caption)
                        VStack(alignment: .leading, spacing: 2) {
                            ForEach(byePlayers) { b in
                                Text("\(b.name) — advances this round")
                                    .fontWeight(.semibold)
                                    .foregroundColor(AppTheme.textPrimary)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }

                // Matches
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(matches) { match in
                            VStack(spacing: 12) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(match.player1.name)
                                            .fontWeight(.semibold)
                                            .foregroundColor(AppTheme.textPrimary)
                                        Text("Elo \(match.player1.currentElo)")
                                            .font(.caption)
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                    Spacer()
                                    Text("VS")
                                        .font(.headline.bold())
                                        .foregroundColor(AppTheme.highlight)
                                        .frame(minWidth: 48)
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text(match.player2.name)
                                            .fontWeight(.semibold)
                                            .foregroundColor(AppTheme.textPrimary)
                                        Text("Elo \(match.player2.currentElo)")
                                            .font(.caption)
                                            .foregroundColor(AppTheme.textSecondary)
                                    }
                                }

                                if let winner = match.winner {
                                    HStack {
                                        Text("Winner:")
                                            .font(.caption)
                                            .foregroundColor(AppTheme.textSecondary)
                                        Text(winner.name)
                                            .fontWeight(.semibold)
                                            .foregroundColor(AppTheme.highlight)
                                        Spacer()
                                    }
                                } else {
                                    HStack(spacing: 16) {
                                        NeumorphicChoiceButton(title: "P1 Wins") {
                                            handleWin(match: match, winnerIndex: 1)
                                        }
                                        NeumorphicChoiceButton(title: "P2 Wins") {
                                            handleWin(match: match, winnerIndex: 2)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .padding()
                            .background(AppTheme.card)
                            .cornerRadius(16)
                            .shadow(color: .black.opacity(0.6), radius: 8, x: 6, y: 6)
                        }
                    }
                    .padding(.horizontal)
                }

                Spacer()

                // Controls
                VStack(spacing: 12) {
                    if currentRound < totalRounds {
                        NeumorphicButton(title: "Next Round", icon: "arrow.right") {
                            guard roundResolved else { return }
                            advanceToNextRound()
                        }
                        .opacity(roundResolved ? 1 : 0.5)
                        .disabled(!roundResolved)
                    } else {
                        if roundResolved {
                            let adv = advancingPlayersAfterThisRound
                            if adv.count == 1 {
                                // Champion page
                                VStack(spacing: 20) {
                                    Text("🏆 Congratulations! 🏆")
                                        .font(.title2.bold())
                                        .foregroundColor(AppTheme.highlight)
                                    Text("\(adv[0].name) is the Champion!")
                                        .font(.headline)
                                        .foregroundColor(AppTheme.textPrimary)
                                    Text("Elo: \(adv[0].currentElo)")
                                        .font(.caption)
                                        .foregroundColor(AppTheme.textSecondary)
                                        .padding()

                                    Button(action: {
                                        onUpdatePlayers(allPlayers) // persist all changes
                                        dismiss()
                                    }) {
                                        Text("Return to Lobby")
                                            .font(.subheadline.weight(.semibold))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(AppTheme.card)
                                            .foregroundColor(.white)
                                            .cornerRadius(12)
                                            .shadow(color: .black.opacity(0.6), radius: 6, x: 4, y: 4)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            allPlayers = players
            currentRound = 1
            startRound()
        }
    }

    // MARK: - Round Lifecycle
    private func startRound() {
        var pool = players.shuffled()
        var newMatches: [Match] = []
        var newByes: [Player] = []

        // Handle byes
        if pool.count % 2 != 0 {
            if let idx = pool.firstIndex(where: { !byeHistory.contains($0.id) }) {
                let bye = pool.remove(at: idx)
                newByes.append(bye)
                byeHistory.insert(bye.id)
            } else {
                let bye = pool.removeFirst()
                newByes.append(bye)
                byeHistory.insert(bye.id)
            }
        }

        // Create matches
        while pool.count >= 2 {
            let p1 = pool.removeFirst()
            let p2 = pool.removeFirst()
            newMatches.append(Match(player1: p1, player2: p2, winner: nil))
        }

        matches = newMatches
        byePlayers = newByes
    }

    private func handleWin(match: Match, winnerIndex: Int) {
        guard let idx = matches.firstIndex(where: { $0.id == match.id }) else { return }
        guard matches[idx].winner == nil else { return }

        var p1 = matches[idx].player1
        var p2 = matches[idx].player2
        var winner: Player

        if winnerIndex == 1 {
            EloService.updateElo(winner: &p1, loser: &p2)
            winner = p1
        } else {
            EloService.updateElo(winner: &p2, loser: &p1)
            winner = p2
        }

        matches[idx].winner = winner

        // Update active players and master list
        players = players.map {
            if $0.id == p1.id { return p1 }
            else if $0.id == p2.id { return p2 }
            else { return $0 }
        }

        func upsertToAll(_ p: Player) {
            if let i = allPlayers.firstIndex(where: { $0.id == p.id }) {
                allPlayers[i] = p
            } else {
                allPlayers.append(p)
            }
        }
        upsertToAll(p1)
        upsertToAll(p2)

        // Persist Elo & state
        onUpdatePlayers(allPlayers)
    }

    private func advanceToNextRound() {
        let winners = matches.compactMap { $0.winner }
        players = winners + byePlayers
        onUpdatePlayers(allPlayers)

        if currentRound >= totalRounds { return }
        currentRound += 1
        startRound()
    }
}

// MARK: - Custom Neumorphic Choice Button
struct NeumorphicChoiceButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppTheme.card)
                .foregroundColor(AppTheme.textPrimary)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.6), radius: 6, x: 4, y: 4)
                .shadow(color: .white.opacity(0.05), radius: 4, x: -3, y: -2)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    ContentView()
}

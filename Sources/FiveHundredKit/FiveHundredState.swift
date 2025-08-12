//
//  FiveHundredState.swift
//  FiveHundred
//
//  Created by Derek Chai on 12/08/2025.
//

struct FiveHundredState: GameStateRepresentable {
    var moves: [PlayingCard] {
        []
    }

    var players: [Player] = []

    var playerToPlay: Player {
        get {
            players[playerToPlayIndex]
        }
        set {
            playerToPlayIndex = (playerToPlayIndex + 1) % players.count
        }
    }

    var nextPlayer: Player {
        players[(playerToPlayIndex + 1) % players.count]
    }
    
    private(set) var bid: Bid?
    
    private var playerToPlayIndex: Int = 0
    
    init(players: [Player]) {
        self.players = players
    }
    
    mutating func play(_: PlayingCard) {
        playerToPlay = nextPlayer
    }
}

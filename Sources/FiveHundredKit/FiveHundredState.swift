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
    
    var playerToPlay: Player
    
    var nextPlayer: Player {
        let playerToPlayIndex = players.firstIndex { $0 === playerToPlay }!
        return players[(playerToPlayIndex + 1) % players.count]
    }
    
    private(set) var bid: (player: Player, bid: Bid)?
    
    private var bids: [(player: Player, bid: Bid)] = []
    
    init(players: [Player]) {
        self.players = players
        self.playerToPlay = players[0]
    }
    
    mutating func play(_: PlayingCard) {
        guard bid != nil else {
            fatalError("Bid should not be nil.")
        }
        
        playerToPlay = nextPlayer
    }
    
    mutating func bid(_ bid: Bid) throws {
        if self.bid != nil {
            throw GameError.biddingClosed
        }
        
        guard bids.isEmpty
                || bid == .pass
                || bid > bids.last(where: { $0.bid != .pass })!.bid else {
            throw GameError.invalidBid
        }
        
        bids.append((playerToPlay, bid))
        playerToPlay = nextPlayer
        
        guard bids.count == 4 else { return }
        
        if bids.count(where: { $0.bid == .pass }) == 3 {
            self.bid = bids.last { $0.bid != .pass }
            playerToPlay = players[0]
        } else {
            bids.removeAll()
        }
    }
}

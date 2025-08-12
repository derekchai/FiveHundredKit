//
//  FiveHundredState.swift
//  FiveHundred
//
//  Created by Derek Chai on 12/08/2025.
//

struct FiveHundredState: GameStateRepresentable {
    // MARK: - Properties
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
    
    private var acceptingBids: Bool = true
    
    private var kitty: [PlayingCard] = []
    
    private var discards: [PlayingCard] = []
    
    // MARK: - Initializer
    init(players: [Player]) {
        self.players = players
        self.playerToPlay = players[0]
    }
    
    // MARK: - Functions
    mutating func play(_: PlayingCard) throws {
        guard bid != nil else {
            throw GameError.noBidMade
        }
        
        playerToPlay = nextPlayer
    }
    
    mutating func bid(_ bid: Bid) throws {
        guard acceptingBids else {
            throw BiddingError.biddingClosed
        }
        
        if let lastValuedBid = bids.last(where: { $0.bid != .pass }),
           bid != .pass {
            guard bid > lastValuedBid.bid else {
                throw BiddingError.invalidBid
            }
        }
        
        bids.append((playerToPlay, bid))
        playerToPlay = nextPlayer
        
        guard bids.count == players.count else { return }
        
        self.bid = bids.last { $0.bid != .pass }
        
        if bids.count(where: { $0.bid == .pass }) == players.count {
            playerToPlay = players[0]
            acceptingBids = false
        } else {
            bids.removeAll()
        }
    }
}

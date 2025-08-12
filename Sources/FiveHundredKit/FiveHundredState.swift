//
//  FiveHundredState.swift
//  FiveHundred
//
//  Created by Derek Chai on 12/08/2025.
//

struct FiveHundredState: GameStateRepresentable {
    // MARK: - Properties
    var moves: [PlayingCard] {
        if trick.isEmpty { return hands[playerToPlay] ?? [] }
        
        return []
    }
    
    var players: [Player] = []
    
    var playerToPlay: Player
    
    var nextPlayer: Player {
        let playerToPlayIndex = players.firstIndex { $0 === playerToPlay }!
        return players[(playerToPlayIndex + 1) % players.count]
    }
    
    var bid: (player: Player, bid: Bid)?
    
    var bids: [(player: Player, bid: Bid)] = []
    
    var acceptingBids: Bool = true
    
    /// The trump suit (or no trumps) for this round.
    private var trumps: Trump? {
        guard let bid else { return nil }
        return bid.bid.trumps
    }
    
    /// The lead suit of the trick (or `nil` if no cards comprise the trick).
    private var leadSuit: Suit? {
        if trick.isEmpty { return nil }
        
        switch trick.first!.card {
        case .joker:
            switch trumps {
            case .noTrumps:
                return jokerNominatedSuit
            case .trump(let trumpSuit):
                return trumpSuit
            case nil:
                fatalError("Trumps is nil during play!")
            }
        case .standard(_, let suit):
            return suit
        }
    }
    
    private var jokerNominatedSuit: Suit?
    
    var kitty: [PlayingCard] = []
    
    private var discards: [PlayingCard] = []
    
    var hands: [Player: [PlayingCard]]
    
    private var trick: [(player: Player, card: PlayingCard)] = []
    
    // MARK: - Initializer
    init(players: [Player]) {
        self.players = players
        self.playerToPlay = players[0]
        self.hands = Dictionary(uniqueKeysWithValues: players.map { ($0, []) })
    }
    
    // MARK: - Functions
    /// Checks whether playing `card` in the current game state is legal.
    /// Throws if the play is illegal.
    /// - Parameter card: The card to be played.
    private func validatePlay(of card: PlayingCard) throws {
        let hand = hands[playerToPlay]!
        
        guard hand.contains(where: { $0 == card }) else {
            throw RuleError.playerDoesNotHoldCard
        }
        
        if trick.isEmpty { return }
        
        guard let trumps else {
            fatalError("Trumps not determined!")
        }
        
        let leadSuit = leadSuit!
        
        // If hand contains lead suit...
        if hand.contains(where: {
            switch $0 {
            case .joker:
                switch trumps {
                case .noTrumps:
                    return false
                case .trump(let trumpSuit):
                    return leadSuit == trumpSuit
                }
            case .standard(_, let suit):
                return leadSuit == suit
            }
        }) {
            switch card {
            case .joker:
                switch trumps {
                case .noTrumps:
                    return
                case .trump(let trumpSuit):
                    guard leadSuit == trumpSuit else {
                        throw RuleError.mustFollowSuit
                    }
                }
            case .standard(_, let suit):
                guard leadSuit == suit else {
                    throw RuleError.mustFollowSuit
                }
            }
        }
    }
    
    mutating func play(_ card: PlayingCard) throws {
        guard bid != nil else {
            throw GameError.noBidMade
        }
        
        try validatePlay(of: card)
        
        trick.append((playerToPlay, card))
        
        playerToPlay = nextPlayer
    }

}

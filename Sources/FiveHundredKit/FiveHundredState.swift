//
//  FiveHundredState.swift
//  FiveHundred
//
//  Created by Derek Chai on 12/08/2025.
//

public struct FiveHundredState: GameStateRepresentable {
    // MARK: - Properties
    public var players: [Player] = []
    
    public var playerToPlay: Player
    
    public var nextPlayer: Player {
        let playerToPlayIndex = players.firstIndex { $0 === playerToPlay }!
        return players[(playerToPlayIndex + 1) % players.count]
    }
    
    public var bid: (player: Player, bid: Bid)?
    
    public var bids: [(player: Player, bid: Bid)] = []
    
    public var acceptingBids: Bool = true
    
    public var kitty: [PlayingCard] = []
    
    public var hands: [Player: [PlayingCard]]
    
    // MARK: Private Properties
    private var jokerNominatedSuit: Suit?
    
    private var discards: [PlayingCard] = []
    
    private var trick: [(player: Player, card: PlayingCard)] = []
    
    // MARK: Computed Properties
    /// Returns all legal moves (i.e. cards able to be played) for the player
    /// to play.
    public var moves: [PlayingCard] {
        var moves = [PlayingCard]()
        
        for card in hands[playerToPlay]! {
            do {
                try validatePlay(of: card)
                moves.append(card)
            } catch {}
        }
        
        return moves
    }
    
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
    
    /// A predicate for comparison between two `(Player, PlayingCard)` tuples
    /// determining which beats the other (taking into account lead and trump suits).
    private var trickRankPredicate: (
        (player: Player, card: PlayingCard),
        (player: Player, card: PlayingCard)
    ) -> Bool {
        { p1, p2 in
            guard let leadSuit else { return false }
            guard let trumps else { return false }
            
            return !p1.card.beats(p2.card, leadSuit: leadSuit, trumps: trumps)
        }
    }
    
    /// A predicate for sorting an array of ``PlayingCard``s by ascending
    /// rank-suit order. Rank order: `spades < diamonds < clubs < hearts
    /// < joker`.
    public static var handSortingPredicate: (PlayingCard, PlayingCard) -> Bool {
        func rank(of suit: Suit) -> Int {
            switch suit {
            case .spades: return 0
            case .clubs: return 2
            case .diamonds: return 1
            case .hearts: return 3
            }
        }
        
        return { card1, card2 in
            switch card1 {
            case .joker:
                return false
            case .standard(_, let suit1):
                switch card2 {
                case .joker:
                    return true
                case .standard(_, let suit2):
                    if suit1 != suit2 {
                        return rank(of: suit1) < rank(of: suit2)
                    } else {
                        return card1.noTrumpsRanking < card2.noTrumpsRanking
                    }
                }
            }
        }
    }
    
    // MARK: - Initializer
    public init(players: [Player]) {
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
            case .standard(let rank, let suit):
                if case .trump = trumps,
                   case .jack = rank {
                    return suit.sameColorSuits.contains(leadSuit)
                }
                
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
            case .standard(let rank, let suit):
                if case .trump = trumps,
                   case .jack = rank {
                    guard suit.sameColorSuits.contains(leadSuit) else {
                        throw RuleError.mustFollowSuit
                    }
                    return
                }
                
                guard leadSuit == suit else {
                    throw RuleError.mustFollowSuit
                }
            }
        }
    }
    
    public mutating func play(_ card: PlayingCard) throws {
        guard bid != nil else {
            throw GameError.noBidMade
        }
        
        try validatePlay(of: card)
        
        trick.append((playerToPlay, card))
        hands[playerToPlay]!.removeAll { $0 == card }
        
        if trick.count == players.count {
            guard let winner = trick.max(by: trickRankPredicate)?.player else {
                fatalError("Winner of trick could not be determined")
            }
            
            playerToPlay = winner
            
            trick.removeAll()
        } else {
            playerToPlay = nextPlayer
        }
    }
    
    /// Discards `cards` from the hand of the winner of the bid. Throws if
    /// the bid winner does not contain _any_ one of the cards in `cards`.
    /// - Parameter cards: The cards to discard.
    public mutating func discardFromBidWinner(cards: [PlayingCard]) throws {
        guard cards.count == 3 else {
            throw FiveHundredState.RuleError
                .exactlyThreeCardsMustBeDiscarded
        }
        
        // Check for duplicates
        guard Set(cards).count == cards.count else {
            throw FiveHundredState.RuleError
                .sameCardCannotBeDiscardedMultipleTimes
        }
        
        guard let winner = bid?.player,
        let hand = hands[winner] else {
            fatalError("Bid must not be nil")
        }
        
        for card in cards where !hand.contains(card) {
            throw FiveHundredState.RuleError.playerDoesNotHoldCard
        }
        
        hands[winner]?.removeAll { cards.contains($0) }
        
        hands[winner]?.sort(by: FiveHundredState.handSortingPredicate)
    }
    
    /// Returns `player`'s sorted hand.
    /// - Parameter player: A player.
    /// - Returns: The player's sorted hand, or `nil` if the player was not
    /// found.
    public func hand(of player: Player) -> [PlayingCard]? {
        guard let hand = hands[player] else { return nil }
        
        return hand
    }
}

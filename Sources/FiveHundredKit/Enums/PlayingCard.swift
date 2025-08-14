//
//  PlayingCard.swift
//  FiveHundred
//
//  Created by Derek Chai on 12/08/2025.
//

import Foundation

public enum PlayingCard: MoveRepresentable, Equatable, Hashable {
    case joker
    case standard(Rank, Suit)
    
    /// Returns a shuffled 500 deck containing red 4s, all cards 5 through to
    /// ace, and one joker.
    public static var shuffled500Deck: [PlayingCard] {
        let fullRanks: [Rank] = [
            .five,
            .six,
            .seven,
            .eight,
            .nine,
            .ten,
            .jack,
            .queen,
            .king,
            .ace
        ]
        
        let deck: [PlayingCard] = [.joker]
        + [Suit.diamonds, Suit.hearts].map { .standard(.four, $0 ) }
        + fullRanks.flatMap { rank in
            Suit.allCases.map { suit in .standard(rank, suit)}}
        
        return deck.shuffled()
    }
    
    public var noTrumpsRanking: Int {
        switch self {
        case .joker: return 15
        case .standard(let rank, _):
            switch rank {
            case .four: return 4
            case .five: return 5
            case .six: return 6
            case .seven: return 7
            case .eight: return 8
            case .nine: return 9
            case .ten: return 10
            case .jack: return 11
            case .queen: return 12
            case .king: return 13
            case .ace: return 14
            }
        }
    }
    
    private var trumpsRanking: Int {
        switch self {
        case .joker:
            return 16
        case .standard(let rank, _):
            switch rank {
            case .four: return 4
            case .five: return 5
            case .six: return 6
            case .seven: return 7
            case .eight: return 8
            case .nine: return 9
            case .ten: return 10
            case .queen: return 12
            case .king: return 13
            case .ace: return 14
            case .jack: return 15
            }
        }
    }
    
    /// Initializes a new ``PlayingCard`` by parsing a string. If the parser
    /// is unable to parse the string, returns `nil`.
    ///
    /// `input` can be:
    /// - Joker: `j`, `joker`
    /// - Standard card: `rs` where:
    ///     - `r` is one of {4, 5, 6, 7, 8, 9, 10, t, j, q, k, 1, a}
    ///     - `s` is one of {s, c, d, h}
    /// - Parameter input: The input string.
    public init?(parsedFrom input: String) {
        let string = input.lowercased()
            .filter { !$0.isWhitespace }
        
        if string == "j" || string == "joker" {
            self = .joker
            return
        }
        
        let rank: Rank
        let suit: Suit
        
        let i = string.index(before: string.endIndex)
        
        switch string[..<i] {
        case "4": rank = .four
        case "5": rank = .five
        case "6": rank = .six
        case "7": rank = .seven
        case "8": rank = .eight
        case "9": rank = .nine
        case "10", "t": rank = .ten
        case "j": rank = .jack
        case "q": rank = .queen
        case "k": rank = .king
        case "1", "a": rank = .ace
            
        default: return nil
        }
        
        switch string.last {
        case "s": suit = .spades
        case "c": suit = .clubs
        case "d": suit = .diamonds
        case "h": suit = .hearts
            
        default: return nil
        }
        
        self = .standard(rank, suit)
    }
    
    /// Determines whether `self` beats `card` in terms of ranking, taking
    /// into account trump suits (and the changed order; i.e. bowers). Assumes
    /// that both cards are of the same suit (taking into account bowers/jokers
    /// being trump suit).
    /// - Parameters:
    ///   - card: The card to compare against.
    ///   - trumps: The trump suit (or no trumps).
    /// - Returns: `true` if `self` is stronger than `card`; `false` otherwise.
    public func beats(_ other: PlayingCard,
                      leadSuit: Suit, trumps: Trump) -> Bool {
        switch trumps {
        case .noTrumps:
            switch self {
            case .joker:
                return other != .joker
            case .standard(_, let thisSuit):
                switch other {
                case .joker:
                    return false
                case .standard(_, let otherSuit):
                    if thisSuit == leadSuit && otherSuit != leadSuit {
                        return true
                    } else if thisSuit != leadSuit && otherSuit == leadSuit {
                        return false
                    } else if thisSuit == otherSuit {
                        return self.noTrumpsRanking > other.noTrumpsRanking
                    } else {
                        return false
                    }
                }
            }
            
        case .trump(let trumpSuit):
            switch self {
            case .joker:
                return other != .joker
            case .standard(_, let thisSuit):
                switch other {
                case .joker:
                    return false
                case .standard(_, let otherSuit):
                    let thisTrumpSuited = thisSuit == trumpSuit
                    || self.isOffJack(trumpSuit: trumpSuit)
                    
                    let otherTrumpSuited = otherSuit == trumpSuit
                    || other.isOffJack(trumpSuit: trumpSuit)
                    
                    if thisTrumpSuited, !otherTrumpSuited {
                        return true
                    } else if !thisTrumpSuited, otherTrumpSuited {
                        return false
                    } else if thisTrumpSuited, otherTrumpSuited {
                        return self.trumpsRanking > other.trumpsRanking
                    } else {
                        if thisSuit == leadSuit, otherSuit != leadSuit {
                            return true
                        } else if thisSuit != leadSuit, otherSuit == leadSuit {
                            return false
                        } else if thisSuit == leadSuit, otherSuit == leadSuit {
                            return self.noTrumpsRanking > other.noTrumpsRanking
                        } else {
                            return false
                        }
                    }
                }
            }
        }
    }
    
    /// Determines whether this ``PlayingCard`` is the off-jack (jack of
    /// the same colour as the trump suit).
    /// - Parameter trumpSuit: The trump suit.
    /// - Returns: `true` if this is the off-jack.
    private func isOffJack(trumpSuit: Suit) -> Bool {
        guard case .standard(let rank, let suit) = self else {
            return false
        }
        
        guard rank == .jack else { return false }
        
        return suit.sameColorSuits.contains(trumpSuit)
    }
}

extension PlayingCard: CustomStringConvertible {
    public var description: String {
        switch self {
        case .joker:
            return "Joker"
        case .standard(let rank, let suit):
            return rank.description + suit.description
        }
    }
}

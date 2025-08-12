//
//  PlayingCard.swift
//  FiveHundred
//
//  Created by Derek Chai on 12/08/2025.
//

import Foundation

enum PlayingCard: MoveRepresentable {
    case joker
    case standard(Rank, Suit)
    
    /// Returns a shuffled 500 deck containing red 4s, all cards 5 through to
    /// ace, and one joker.
    static var shuffled500Deck: [PlayingCard] {
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
        
        return [.joker]
        + Suit.redSuits.map { .standard(.four, $0 ) }
        + fullRanks.flatMap { rank in
            Suit.allCases.map { suit in .standard(rank, suit)}}
    }
}

extension PlayingCard: CustomStringConvertible {
    var description: String {
        switch self {
        case .joker:
            return "Joker"
        case .standard(let rank, let suit):
            return rank.description + suit.description
        }
    }
}

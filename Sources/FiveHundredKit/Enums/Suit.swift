//
//  Suit.swift
//  FiveHundred
//
//  Created by Derek Chai on 12/08/2025.
//

import Foundation

public enum Suit: CaseIterable, CustomStringConvertible {
    case spades
    case clubs
    case diamonds
    case hearts
    
    public var description: String {
        switch self {
        case .spades: "♠"
        case .clubs: "♣"
        case .diamonds: "♢"
        case .hearts: "♡"
        }
    }
    
    /// Returns a set of the same-colored suits as `self`.
    var sameColorSuits: Set<Suit> {
        switch self {
        case .spades, .clubs:
            return Set([.spades, .clubs])
        case .diamonds, .hearts:
            return Set([.diamonds, .hearts])
        }
    }
}

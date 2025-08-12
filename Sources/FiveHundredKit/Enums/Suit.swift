//
//  Suit.swift
//  FiveHundred
//
//  Created by Derek Chai on 12/08/2025.
//

import Foundation

enum Suit: CaseIterable, CustomStringConvertible {
    case spades
    case clubs
    case diamonds
    case hearts
    
    static let redSuits: [Suit] = [.diamonds, .hearts]
    static let blackSuits: [Suit] = [.spades, .clubs]
    
    var description: String {
        switch self {
        case .spades: "♠"
        case .clubs: "♣"
        case .diamonds: "♢"
        case .hearts: "♡"
        }
    }
}

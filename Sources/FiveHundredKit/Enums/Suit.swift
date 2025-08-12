//
//  Suit.swift
//  FiveHundred
//
//  Created by Derek Chai on 12/08/2025.
//

import Foundation

enum Suit: CaseIterable {
    case spades
    case clubs
    case diamonds
    case hearts
    
    static let redSuits: [Suit] = [.diamonds, .hearts]
    static let blackSuits: [Suit] = [.spades, .clubs]
}

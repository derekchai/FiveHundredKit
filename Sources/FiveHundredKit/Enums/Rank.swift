//
//  Rank.swift
//  FiveHundred
//
//  Created by Derek Chai on 12/08/2025.
//

import Foundation

public enum Rank: CaseIterable, CustomStringConvertible {
    // 2s, 3s, black 4s removed in 500.
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case ten
    case jack
    case queen
    case king
    case ace
    
    public var description: String {
        switch self {
        case .four: "4"
        case .five: "5"
        case .six: "6"
        case .seven: "7"
        case .eight: "8"
        case .nine: "9"
        case .ten: "10"
        case .jack: "J"
        case .queen: "Q"
        case .king: "K"
        case .ace: "A"
        }
    }
}

//
//  Trump.swift
//  FiveHundredKit
//
//  Created by Derek Chai on 12/08/2025.
//

import Foundation

public enum Trump: CustomStringConvertible {
    case noTrumps
    case trump(Suit)
    
    /// Returns the Unicode suit character for trumps or "NT" for no trumps.
    public var description: String {
        switch self {
        case .noTrumps:
            "NT"
        case .trump(let suit):
            suit.description
        }
    }
}

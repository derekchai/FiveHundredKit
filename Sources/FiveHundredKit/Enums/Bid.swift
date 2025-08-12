//
//  Bid.swift
//  FiveHundredKit
//
//  Created by Derek Chai on 12/08/2025.
//

enum Bid {
    case pass
    
    case misere
    case openMisere
    
    case noTrumps(Int)
    case standard(Int, Suit)
}

extension Bid {
    var points: Int {
        switch self {
        case .pass:
            return 0
        case .misere:
            return 250
        case .openMisere:
            return 500
        case .noTrumps(let int):
            return 120 + (int - 6) * 100
        case .standard(let int, let suit):
            let summand: Int
            
            switch suit {
            case .spades:
                summand = 40
            case .clubs:
                summand = 60
            case .diamonds:
                summand = 80
            case .hearts:
                summand = 100
            }
            
            return summand + (int - 6) * 100
        }
    }
}

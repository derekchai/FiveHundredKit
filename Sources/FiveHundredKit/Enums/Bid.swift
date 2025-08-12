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

//
//  FiveHundredStateTests+Play.swift
//  FiveHundredKit
//
//  Created by Derek Chai on 13/08/2025.
//

import Testing
@testable import FiveHundredKit

@Suite("Gameplay")
class FiveHundredStatePlayTests {
    
    let north = Player(name: "North")
    let east = Player(name: "East")
    let south = Player(name: "South")
    let west = Player(name: "West")
    
    var state: FiveHundredState
    
    init() {
        state = FiveHundredState(players: [north, east, south, west])
    }

    
    @Test("Correctly get all legal moves")
    func varTestGetLegalMoves() async throws {
        let northHand: [PlayingCard] = [
            .standard(.ace, .spades),       // As
            .standard(.king, .spades)       // Ks
        ]
        
        let eastHand: [PlayingCard] = [
            .standard(.queen, .spades),     // Qs
            .joker,                         // Joker
            .standard(.ace, .hearts)        // Ah
        ]
        
        #expect(throws: Never.self) {
            try state.setHand(of: north, to: northHand)
            try state.setHand(of: east, to: eastHand)
            
            try state.bid(.standard(6, .spades)) // N
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass)
            
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass) // Conclude bidding; N wins bid with 6 spades.
            
            // N leads.
        }
        
        #expect(state.moves == northHand)
        
        try state.play(.standard(.ace, .spades))        // N plays As
        
        #expect(state.moves == [
            .standard(.queen, .spades),
            .joker
        ]) // Ah illegal to play as East must follow suit
    }
    
}

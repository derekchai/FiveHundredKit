//
//  FiveHundredStateTests.swift
//  FiveHundredKit
//
//  Created by Derek Chai on 12/08/2025.
//

import Testing
@testable import FiveHundredKit

class FiveHundredStateTests {
    let north, east, south, west: Player
    var state: FiveHundredState
    
    init() {
        north = Player(name: "North")
        east = Player(name: "East")
        south = Player(name: "South")
        west = Player(name: "West")
        
        state = FiveHundredState(players: [north, east, south, west])
    }
    
    @Test func testPlayerOrder() async throws {
        do {
            try state.bid(.misere)
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass)
        } catch let e {
            fatalError(e.localizedDescription)
        }
        
        #expect(state.playerToPlay === north)
        #expect(state.nextPlayer === east)

        state.play(.joker)
        
        #expect(state.playerToPlay === east)
        #expect(state.nextPlayer === south)

        state.play(.joker)

        #expect(state.playerToPlay === south)
        #expect(state.nextPlayer === west)
        
        state.play(.joker)
        
        #expect(state.playerToPlay === west)
        #expect(state.nextPlayer === north)

        state.play(.joker)
        
        #expect(state.playerToPlay === north)
        #expect(state.nextPlayer === east)
    }
    
    @Test func testBidding() async throws {
        #expect(throws: Never.self) {
            try state.bid(.pass) // N
            try state.bid(.standard(6, .spades)) // E
            try state.bid(.pass) // S
            try state.bid(.pass) // W
            
            try state.bid(.pass) // N: passing on bid re-entry
            try state.bid(.standard(6, .clubs)) // E: overbid self
            try state.bid(.pass) // S: passing on bid re-entry
            try state.bid(.standard(7, .clubs)) // W: overbid team
            
            try state.bid(.pass) // N
            try state.bid(.pass) // E
            try state.bid(.pass) // S
            try state.bid(.pass) // W
        }
        
        // Bidding should have concluded (after all players pass in a bidding
        // round).
        
        #expect(throws: FiveHundredState.GameError.biddingClosed.self) {
            try state.bid(.pass)
        }
    }
    
    @Test func testUnderBidding() async throws {
        #expect(throws: Never.self) {
            try state.bid(.standard(10, .hearts))
        }
        
        #expect(throws: FiveHundredState.GameError.invalidBid.self) {
            try state.bid(.standard(8, .hearts))
        }
        
        #expect(throws: FiveHundredState.GameError.invalidBid.self) {
            try state.bid(.misere)
        }
    }
}




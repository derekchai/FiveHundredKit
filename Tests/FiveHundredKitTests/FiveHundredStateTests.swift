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
        
        do {
            try state.bid(.misere)
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass)
        } catch {}
    }
    
    @Test func testPlayerOrder() async throws {
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
}




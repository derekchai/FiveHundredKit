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
    
    @Test("Player order is as expected")
    func testPlayerOrder() async throws {
        #expect(throws: Never.self) {
            try state.bid(.misere)
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass)
        }
        
        #expect(state.playerToPlay === north)
        #expect(state.nextPlayer === east)

        try state.play(.joker)
        
        #expect(state.playerToPlay === east)
        #expect(state.nextPlayer === south)

        try state.play(.joker)

        #expect(state.playerToPlay === south)
        #expect(state.nextPlayer === west)
        
        try state.play(.joker)
        
        #expect(state.playerToPlay === west)
        #expect(state.nextPlayer === north)

        try state.play(.joker)
        
        #expect(state.playerToPlay === north)
        #expect(state.nextPlayer === east)
    }
    
    @Test("Playing without any bids made throws error")
    func testPlayWithoutBid() async throws {
        #expect(throws: FiveHundredState.GameError.noBidMade) {
            try state.play(.joker)
        }
    }
    
    @Test("Bidding works as expected")
    func testBidding() async throws {
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
        
        #expect(throws: FiveHundredState.BiddingError.biddingClosed.self) {
            try state.bid(.pass)
        }
    }
    
    @Test("Under-bidding throws error")
    func testUnderBidding() async throws {
        #expect(throws: Never.self) {
            try state.bid(.standard(10, .hearts))
        }
        
        #expect(throws: FiveHundredState.BiddingError.invalidBid.self) {
            try state.bid(.standard(8, .hearts))
        }
        
        #expect(throws: FiveHundredState.BiddingError.invalidBid.self) {
            try state.bid(.misere)
        }
    }
    
    @Test("10 cards to players and 3 cards to kitty dealt in deal")
    func testDeal() async throws {
        state.deal()
        
        #expect(state.kitty.count == 3)
        
        state.players.forEach { player in
            #expect(self.state.hands[player]?.count == 10)
        }
        
        for player in state.players {
            print(state.hands[player]?.description)
        }
    }
}




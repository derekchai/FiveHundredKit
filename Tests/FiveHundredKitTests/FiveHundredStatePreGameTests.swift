//
//  FiveHundredStatePreGameTests.swift
//  FiveHundredKit
//
//  Created by Derek Chai on 12/08/2025.
//

import Testing
@testable import FiveHundredKit

@Suite("Pre-Game Tests")
class FiveHundredStatePreGameTests {
    let north = Player(name: "North")
    let east = Player(name: "East")
    let south = Player(name: "South")
    let west = Player(name: "West")
    
    var state: FiveHundredState
    
    init() {
        state = FiveHundredState(players: [north, east, south, west])
    }
    
    @Test("Player order is as expected")
    func testPlayerOrder() async throws {
        #expect(throws: Never.self) {
            try state.setHand(of: north, to: [.standard(.ace, .spades)])
            try state.setHand(of: east, to: [.standard(.king, .spades)])
            try state.setHand(of: south, to: [.standard(.queen, .spades)])
            try state.setHand(of: west, to: [.standard(.ten, .spades)])
            
            try state.bid(.standard(6, .spades))
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass)
            
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass) // Conclude bidding (N wins).
            
            // N leads.
        }
        
        #expect(state.playerToPlay === north)
        #expect(state.nextPlayer === east)
        
        #expect(throws: Never.self) {
            try state.play(.standard(.ace, .spades))            // N: As
        }
        
        #expect(state.playerToPlay === east)
        #expect(state.nextPlayer === south)
        
        #expect(throws: Never.self) {
            try state.play(.standard(.king, .spades))           // E: Ks
        }
        
        #expect(state.playerToPlay === south)
        #expect(state.nextPlayer === west)
        
        #expect(throws: Never.self) {
            try state.play(.standard(.queen, .spades))          // S: Qs
        }
        
        #expect(state.playerToPlay === west)
        #expect(state.nextPlayer === north)
        
        #expect(throws: Never.self) {
            try state.play(.standard(.ten, .spades))            // W: Ts
        }
        
        // North wins trick with As (spades trump)
        
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
            try state.bid(.pass)                    // N
            try state.bid(.standard(6, .spades))    // E
            try state.bid(.pass)                    // S
            try state.bid(.pass)                    // W
            
            try state.bid(.pass)                // N: passing on bid re-entry
            try state.bid(.standard(6, .clubs))     // E: overbid self
            try state.bid(.pass)                // S: passing on bid re-entry
            try state.bid(.standard(7, .clubs))     // W: overbid team
            
            try state.bid(.pass)                    // N
            try state.bid(.pass)                    // E
            try state.bid(.pass)                    // S
            try state.bid(.pass)                    // W
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
    }
    
    @Test("Bid winner leads first trick")
    func testBidWinnerLeadsFirstTrick() async throws {
        #expect(throws: Never.self) {
            try state.bid(.pass)                    // N
            try state.bid(.pass)                    // E
            try state.bid(.pass)                    // S
            try state.bid(.standard(6, .spades))    // W
            
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass) // Conclude bidding
        }
        
        #expect(state.playerToPlay === west)
    }
    
    @Test("Redeal when all plays pass without bids made")
    func testRedeal() async throws {
        state.deal()
        
        let northHand = state.hands[north]
        let eastHand = state.hands[east]
        
        #expect(throws: Never.self) {
            try state.bid(.pass)        // N
            try state.bid(.pass)        // E
            try state.bid(.pass)        // S
            try state.bid(.pass)        // W
            
            // Cards re-dealt.
        }
        
        #expect( state.hands[north] != northHand
                 || state.hands[east] != eastHand )
    }
    
    @Test("Bid after redeal")
    func testBidAfterRedeal() async throws {
        await #expect(throws: Never.self) {
            try await testRedeal()
        }
        
        try state.bid(.standard(6, .spades))
        try state.bid(.pass)
        try state.bid(.pass)
        try state.bid(.pass)
        
        try state.bid(.pass)
        try state.bid(.pass)
        try state.bid(.pass)
        try state.bid(.pass)            // Bidding concludes.
        
        #expect(throws: FiveHundredState.BiddingError.biddingClosed.self) {
            try state.bid(.pass)
        }
    }
    
    @Test("Kitty added to bid-winner's hand")
    func testKittyAddedToBidWinnerHand() async throws {
        let kitty: [PlayingCard] = [
            .joker,
            .standard(.jack, .hearts),
            .standard(.jack, .diamonds)
        ]
        
        state.kitty = kitty
        
        try state.bid(.standard(6, .spades))    // N
        try state.bid(.pass)
        try state.bid(.pass)
        try state.bid(.pass)
        
        try state.bid(.pass)
        try state.bid(.pass)
        try state.bid(.pass)
        try state.bid(.pass)                    // N wins bid with 6 spades.
        
        #expect(state.hands[north] == kitty)
    }
    
    @Test("Discard after kitty added to bid-winner's hand")
    func testDiscardAfterKittyAddedToBidWinnerHand() async throws {
        try await testKittyAddedToBidWinnerHand()
        
        // N wins bid (6 spades) and gets kitty (Joker, Jh, Jd)
        
        try state.discardFromBidWinner(cards: [.joker,
                                           .standard(.jack, .hearts),
                                           .standard(.jack, .diamonds)])
        
        #expect(state.hands[north] == [])
    }
    
    @Test("Discard function throws if player does not hold card")
    func testDiscardThrowsIfPlayerDoesNotHoldCard() async throws {
        try await testKittyAddedToBidWinnerHand()
        
        // N wins bid (6 spades) and gets kitty (Joker, Jh, Jd)
        
        #expect(throws: FiveHundredState.RuleError.self) {
            try state.discardFromBidWinner(cards: [.standard(.ten, .spades),
                                                   .standard(.jack, .hearts),
                                                   .standard(.jack, .diamonds)])
        }
    }
    
    @Test("Discard function throws if duplicate cards discard")
    func testDiscardFunctionThrowsIfDuplicatedCards() async throws {
        try await testKittyAddedToBidWinnerHand()
        
        // N wins bid (6 spades) and gets kitty (Joker, Jh, Jd)
        
        #expect(throws: FiveHundredState.RuleError.self) {
            try state.discardFromBidWinner(cards: [.standard(.jack, .hearts),
                                                   .standard(.jack, .hearts),
                                                   .standard(.jack, .diamonds)])
        }
    }
}




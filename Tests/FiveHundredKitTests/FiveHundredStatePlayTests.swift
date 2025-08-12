//
//  FiveHundredStateTests+Play.swift
//  FiveHundredKit
//
//  Created by Derek Chai on 13/08/2025.
//

import Testing
@testable import FiveHundredKit

@Suite("Gameplay Tests")
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
    
    @Test("Must follow suit")
    func testMustFollowSuit() async throws {
        #expect(throws: Never.self) {
            try state.setHand(of: north, to: [.standard(.ace, .spades)])
            try state.setHand(of: east, to: [.standard(.king, .spades),
                                             .standard(.queen, .hearts)])
            try state.setHand(of: south, to: [.standard(.five, .diamonds)])
            try state.setHand(of: west, to: [.joker, .standard(.five, .hearts)])
            
            try state.bid(.standard(6, .spades))
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass)
            
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass) // Conclude bidding; bid is 6 spades.
            
            // N leads.
            
            try state.play(.standard(.ace, .spades))        // N plays As.
        }
        
        #expect(throws: FiveHundredState.RuleError.mustFollowSuit.self) {
            try state.play(.standard(.queen, .hearts))      // E plays Qh but
            // can follow suit.
        }
        
        #expect(throws: Never.self) {
            try state.play(.standard(.king, .spades))       // E plays Ks.
            
            try state.play(.standard(.five, .diamonds))     // S has no spades
            // and can discard.
        }
        
        #expect(throws: FiveHundredState.RuleError.mustFollowSuit.self) {
            // W tries to play 5h but can follow suit with joker.
            try state.play(.standard(.five, .hearts))
        }
        
        #expect(throws: Never.self) {
            try state.play(.joker)                          // W plays joker.
        }
    }
    
    @Test("Bowers count as trump suit in trumped game")
    func varTestBowersCountAsTrumpSuit() async throws {
        try state.setHand(of: north, to: [.standard(.ace, .spades)])
        try state.setHand(of: east, to: [.standard(.jack, .clubs),
                                         .standard(.queen, .hearts)])
        
        try state.bid(.standard(6, .spades))
        try state.bid(.pass)
        try state.bid(.pass)
        try state.bid(.pass)
        
        try state.bid(.pass)
        try state.bid(.pass)
        try state.bid(.pass)
        try state.bid(.pass) // Conclude bidding; bid is 6 spades.
        
        try state.play(.standard(.ace, .spades))            // N plays As
        
        #expect(throws: Error.self) {
            // Invalid move as Jc (left bower) is trump suited.
            try state.play(.standard(.queen, .hearts))      // E plays Qh
        }
        
        #expect(throws: Never.self) {
            try state.play(.standard(.jack, .clubs))
        }
    }
    
    @Test("Bowers do not count as trump suit in no trumps game")
    func varTestBowersDoNotCountAsTrumpSuitInNoTrumps() async throws {
        try state.setHand(of: north, to: [.standard(.ace, .spades)])
        try state.setHand(of: east, to: [.standard(.jack, .clubs),
                                         .standard(.queen, .hearts)])
        
        try state.bid(.noTrumps(6))
        try state.bid(.pass)
        try state.bid(.pass)
        try state.bid(.pass)
        
        try state.bid(.pass)
        try state.bid(.pass)
        try state.bid(.pass)
        try state.bid(.pass) // Conclude bidding; bid is 6 NT.
        
        try state.play(.standard(.ace, .spades))            // N plays As
        
        #expect(throws: Never.self) {
            try state.play(.standard(.queen, .hearts))      // E plays Qh
        }
    }
    
    @Test("Gameplay 1")
    func testGameplay1() async throws {
        try state.setHand(of: north, to: FiveHundredStatePlayTests.northHand)
        try state.setHand(of: east, to: FiveHundredStatePlayTests.eastHand)
        try state.setHand(of: south, to: FiveHundredStatePlayTests.southHand)
        try state.setHand(of: west, to: FiveHundredStatePlayTests.westHand)
        
        state.kitty = FiveHundredStatePlayTests.kitty
        
        #expect(Bool(false), "Implement kitty exchange")
    }
}

extension FiveHundredStatePlayTests {
    static let northHand: [PlayingCard] = [
        .standard(.ace, .spades),    // A♠
        .standard(.queen, .clubs),   // Q♣
        .standard(.ten, .diamonds),  // 10♢
        .standard(.four, .diamonds), // 4♢
        .standard(.six, .spades),    // 6♠
        .standard(.king, .hearts),   // K♡
        .standard(.nine, .clubs),    // 9♣
        .standard(.eight, .hearts),  // 8♡
        .standard(.five, .diamonds), // 5♢
        .standard(.jack, .spades)    // J♠
    ]
    
    static let eastHand: [PlayingCard] = [
        .standard(.queen, .spades),  // Q♠
        .standard(.seven, .clubs),   // 7♣
        .standard(.ten, .hearts),    // 10♡
        .standard(.ace, .clubs),     // A♣
        .standard(.nine, .spades),   // 9♠
        .standard(.eight, .diamonds),// 8♢
        .joker,                      // Joker
        .standard(.five, .clubs),    // 5♣
        .standard(.king, .diamonds), // K♢
        .standard(.six, .clubs)      // 6♣
    ]
    
    static let southHand: [PlayingCard] = [
        .standard(.king, .spades),   // K♠
        .standard(.queen, .hearts),  // Q♡
        .standard(.jack, .clubs),    // J♣
        .standard(.ten, .clubs),     // 10♣
        .standard(.nine, .hearts),   // 9♡
        .standard(.eight, .clubs),   // 8♣
        .standard(.seven, .hearts),  // 7♡
        .standard(.five, .hearts),   // 5♡
        .standard(.seven, .diamonds),// 7♢
        .standard(.ace, .diamonds)   // A♢
    ]
    
    static let westHand: [PlayingCard] = [
        .standard(.jack, .hearts),   // J♡
        .standard(.ten, .spades),    // 10♠
        .standard(.four, .hearts),   // 4♡
        .standard(.six, .hearts),    // 6♡
        .standard(.seven, .spades),  // 7♠
        .standard(.nine, .diamonds), // 9♢
        .standard(.eight, .spades),  // 8♠
        .standard(.jack, .diamonds), // J♢
        .standard(.king, .clubs),    // K♣
        .standard(.five, .spades)    // 5♠
    ]
    
    static let kitty: [PlayingCard] = [
        .standard(.ace, .hearts),    // A♡
        .standard(.six, .diamonds),  // 6♢
        .standard(.queen, .diamonds) // Q♢
    ]
}

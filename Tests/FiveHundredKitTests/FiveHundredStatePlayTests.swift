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
    
    let northHand: [PlayingCard] = [
        .standard(.ace, .spades),    // A♠
        .standard(.jack, .spades),    // J♠
        .standard(.six, .spades),    // 6♠
        .standard(.ten, .diamonds),  // 10♢
        .standard(.five, .diamonds), // 5♢
        .standard(.four, .diamonds), // 4♢
        .standard(.queen, .clubs),   // Q♣
        .standard(.nine, .clubs),    // 9♣
        .standard(.king, .hearts),   // K♡
        .standard(.eight, .hearts),  // 8♡
    ]
    
    let eastHand: [PlayingCard] = [
        .joker,                      // Joker
        .standard(.queen, .spades),   // Q♠
        .standard(.nine, .spades),    // 9♠
        .standard(.king, .diamonds),  // K♢
        .standard(.eight, .diamonds), // 8♢
        .standard(.ace, .clubs),      // A♣
        .standard(.seven, .clubs),    // 7♣
        .standard(.six, .clubs),      // 6♣
        .standard(.five, .clubs),     // 5♣
        .standard(.ten, .hearts)      // 10♡
    ]
    
    let southHand: [PlayingCard] = [
        .standard(.king, .spades),    // K♠
        .standard(.ace, .diamonds),   // A♢
        .standard(.seven, .diamonds), // 7♢
        .standard(.jack, .clubs),     // J♣
        .standard(.ten, .clubs),      // 10♣
        .standard(.eight, .clubs),    // 8♣
        .standard(.queen, .hearts),   // Q♡
        .standard(.nine, .hearts),    // 9♡
        .standard(.seven, .hearts),   // 7♡
        .standard(.five, .hearts)     // 5♡
    ]
    
    let westHand: [PlayingCard] = [
        .standard(.ten, .spades),     // 10♠
        .standard(.eight, .spades),   // 8♠
        .standard(.seven, .spades),   // 7♠
        .standard(.five, .spades),    // 5♠
        .standard(.nine, .diamonds),  // 9♢
        .standard(.jack, .diamonds),  // J♢
        .standard(.king, .clubs),     // K♣
        .standard(.jack, .hearts),    // J♡
        .standard(.six, .hearts),     // 6♡
        .standard(.four, .hearts)     // 4♡
    ]
    
    let kitty: [PlayingCard] = [
        .standard(.six, .diamonds),   // 6♢
        .standard(.queen, .diamonds), // Q♢
        .standard(.ace, .hearts)      // A♡
    ]
    
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
    
    @Test("Trick winner leads next bid")
    func testTrickWinnerLeadsNextBid() async throws {
        #expect(throws: Never.self) {
            try state.setHand(of: north, to: [.standard(.four, .hearts)])
            try state.setHand(of: east, to: [.standard(.five, .hearts)])
            try state.setHand(of: south, to: [.standard(.six, .hearts)])
            try state.setHand(of: west, to: [.standard(.seven, .hearts)])
        }
        
        #expect(throws: Never.self) {
            try state.bid(.noTrumps(6))     // N
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass)
            
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass)            // N wins bid with 6NT
        }
        
        #expect(throws: Never.self) {
            try state.play(.standard(.four, .hearts))   // N: 4h
            try state.play(.standard(.five, .hearts))   // E: 5h
            try state.play(.standard(.six, .hearts))    // S: 6h
            try state.play(.standard(.seven, .hearts))  // W: 7h
        }
        
        // West wins trick with 7h
        
        #expect(state.playerToPlay === west)
    }
    
    @Test("Gameplay 1")
    func testGameplay1() async throws {
        try state.setHand(of: north, to: northHand)
        try state.setHand(of: east, to: eastHand)
        try state.setHand(of: south, to: southHand)
        try state.setHand(of: west, to: westHand)
        
        state.kitty = kitty
        
        // North: AJ6s T54d Q9c K8h
        // East : Joker Q9s K8d A765c Th
        // South: Ks A7d JT8c Q975h
        // West : T875s J9d Kc J64h
        
        #expect(throws: Never.self) {
            try state.bid(.standard(6, .spades))    // N: 6s
            try state.bid(.noTrumps(6))             // E: 6NT
            try state.bid(.standard(7, .diamonds))  // S: 7d
            try state.bid(.standard(8, .hearts))    // W: 7h
            
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass)
            try state.bid(.pass)    // Bidding concludes. West wins (7 hearts)
        }
        
        #expect(state.playerToPlay === west)
        
        #expect(throws: Never.self) {
            // West leads first trick.
            
            try state.play(.standard(.four, .hearts))   // W: Jd
            try state.play(.standard(.eight, .hearts))  // N: 8h
            try state.play(.joker)                      // E: Joker
            try state.play(.standard(.five, .hearts))   // S: 5h
        }
        
        #expect(state.playerToPlay === east) // E wins trick with joker
        
        #expect(throws: Never.self) {
            try state.play(.standard(.ten, .hearts))    // E: Th
            try state.play(.standard(.queen, .hearts))  // S: Qh
            try state.play(.standard(.jack, .diamonds)) // W: Jd
            try state.play(.standard(.king, .hearts))   // N: Kh
        }
        
        #expect(state.playerToPlay === west) // W wins with Jd (off-jack)
    }
}

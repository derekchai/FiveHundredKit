//
//  BidTests.swift
//  FiveHundredKit
//
//  Created by Derek Chai on 12/08/2025.
//

import Testing
@testable import FiveHundredKit

struct BidTests {

    @Test func testBidPoints() async throws {
        #expect(Bid.pass.points == 0)
        
        #expect(Bid.misere.points == 250)
        #expect(Bid.openMisere.points == 500)
        
        #expect(Bid.standard(6, .spades).points == 40)
        #expect(Bid.standard(6, .clubs).points == 60)
        #expect(Bid.standard(6, .diamonds).points == 80)
        #expect(Bid.standard(6, .hearts).points == 100)
        #expect(Bid.noTrumps(6).points == 120)
        
        #expect(Bid.standard(7, .spades).points == 140)
        #expect(Bid.standard(7, .clubs).points == 160)
        #expect(Bid.standard(7, .diamonds).points == 180)
        #expect(Bid.standard(7, .hearts).points == 200)
        #expect(Bid.noTrumps(7).points == 120)
    }

}

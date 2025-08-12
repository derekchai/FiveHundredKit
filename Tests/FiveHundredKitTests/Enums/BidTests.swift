//
//  BidTests.swift
//  FiveHundredKit
//
//  Created by Derek Chai on 12/08/2025.
//

import Testing
@testable import FiveHundredKit

struct BidTests {

    @Test("Bid points are calculated correctly")
    func testBidPoints() async throws {
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
        #expect(Bid.noTrumps(7).points == 220)
    }
    
    @Test("Bids are comparable and equatable")
    func testBidComparability() async throws {
        #expect(Bid.pass < Bid.standard(6, .spades))
        
        #expect(Bid.standard(6, .spades) < Bid.standard(6, .clubs))
        
        #expect(Bid.misere > Bid.standard(8, .spades))
        #expect(Bid.misere < Bid.standard(8, .clubs))
        
        #expect(Bid.standard(10, .hearts) == Bid.openMisere)
        
        #expect(Bid.noTrumps(10) > Bid.openMisere)
    }

}
